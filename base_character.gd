# base_character.gd
extends CharacterBody2D
class_name BaseCharacter

@export var character_type: int = Constants.CharacterType.FIGHTER  # Default character type

@onready var health_label = $HP
@onready var health_progress_bar = $HealthProgressBAr
@onready var popuploc = $PopupLocation
@onready var level_label: Label = $LevelLabel
@export var lifesteal_percentage: float = 0.0  # Percentage of damage converted to health
#@onready var skill_name_location: Marker2D = $SkillNameLocation


#skills var
var shield_active: bool = false  # Indicates if the shield is active
var arcane_shield_skill: Skill = null  # Reference to the active Arcane Shield skill
var shield_block_count: int = 0  # Tracks how many attacks can be blocked
var is_stunned: bool = false  # Track stun state
@export var stun_timer: Timer = Timer.new()


# Stats and growths
@export var move_speed: int = 80
@export var attack_range: float = 80.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.5
@export var max_health: int = 100
@export var defense: int = 5

@export var health_growth: int = 20
@export var damage_growth: int = 5
@export var defense_growth: int = 2

# Base stats
@export var base_move_speed: int = 80
@export var base_attack_range: float = 80.0
@export var base_attack_damage: int = 10
@export var base_attack_cooldown: float = 1.5
@export var base_max_health: int = 100
@export var base_defense: int = 5

# Character skill management
var active_skills = []  # Stores the active skills with cooldowns
var learned_skills: Array = []

var current_health: int
@export var attack_timer: Timer = Timer.new()
var target: Node2D  # Current attack target

# Reference to the level system
signal level_up_skill_popup
@onready var level_system = LevelSystem.new()  # Assuming your LevelSystem handles leveling

func _ready():
	current_health = max_health
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))
	add_to_group("PlayerCharacters")

	# Initialize stats and connect level-up signals
	update_stats()
	level_system.connect("leveled_up", Callable(self, "_on_leveled_up"))
	update_level_ui()

	# Initialize stun timer
	stun_timer.one_shot = true
	stun_timer.connect("timeout", Callable(self, "_on_stun_end"))
	add_child(stun_timer)

# Update stats based on equipped items
func update_stats():
	attack_damage = base_attack_damage + (damage_growth * level_system.level)
	defense = base_defense + (defense_growth * level_system.level)
	move_speed = base_move_speed
	max_health = base_max_health + (health_growth * level_system.level)

	for skill in learned_skills:
		if skill != null:
			if skill.name == "Weapon Mastery":
				attack_damage += skill.attack_bonus
				print("Applied weapon mastery bonus: ", skill.attack_bonus)
			elif skill.name == "Defense Mastery":
				defense += skill.defense_bonus
				print("Applied defense mastery bonus: ", skill.defense_bonus)
			elif skill.name == "Crescendo":
				max_health += skill.health_bonus
				print("Applied defense mastery bonus: ", skill.health_bonus)

	current_health = min(current_health, max_health)
	update_health_label()

# Update the health label UI
func update_health_label():
	health_label.text = str(current_health)

# Attack logic
func attack(target: Node2D):
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		apply_lifesteal(attack_damage)  # Apply lifesteal when attacking
		attack_timer.start()

# Apply lifesteal when damage is dealt
func apply_lifesteal(damage_dealt: int) -> void:
	var heal_amount = int(damage_dealt * lifesteal_percentage)
	if heal_amount > 0:
		current_health = min(current_health + heal_amount, max_health)  # Heal the character, but don't exceed max health
		print("Lifesteal: healed", heal_amount, "HP from lifesteal.")
		popuploc.popup(heal_amount)
		update_health_label()

# Handle taking damage
func take_damage(damage: int):
	if shield_active and arcane_shield_skill != null:
		damage = arcane_shield_skill.absorb_damage(damage, self)
	if is_invincible:
		self.sprite.modulate = Color(1,1,0)
		print(name, "is invincible and took no damage!")
		return
	if shield_block_count > 0:
		shield_block_count -= 1
		print("Blocked attack! Remaining blocks:", shield_block_count)
		if shield_block_count == 0:
			print("Shield has been broken!")
	else:
		var reduced_damage = max(damage - defense, 0)
		current_health -= reduced_damage
		popuploc.popup(-reduced_damage)
		update_health_label()
		health_progress_bar.value = current_health
		if current_health <= 0:
			die()

# Character dies
func die():
	queue_free()

# Handle timeout after attack
func _on_attack_timeout():
	pass

# Find nearest target for attack or healing
func find_nearest_target(group_name: String) -> Node2D:
	var nearest_node: Node2D = null
	var shortest_distance = INF

	for node in get_tree().get_nodes_in_group(group_name):
		var distance = global_position.distance_to(node.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_node = node

	return nearest_node

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

# Receive healing
func receive_heal(heal: int):
	current_health += heal
	popuploc.popup(heal)
	current_health = clamp(current_health, 0, max_health)
	update_health_label()
	health_progress_bar.value = current_health

# Handle level-up and stat growth
func _on_leveled_up():
	max_health += health_growth
	attack_damage += damage_growth
	defense += defense_growth
	current_health = max_health
	update_stats()
	update_level_ui()

# Update the level label UI
func update_level_ui():
	level_label.text = name + " Lv: " + str(level_system.level)

# Adds XP to all party characters
func add_xp_to_party(amount: int):
	for player in get_tree().get_nodes_in_group("PlayerCharacters"):
		player.level_system.add_xp(amount)
		_on_leveled_up()

# Add global gold when enemy dies
func add_gold(gold: int):
	global.add_currency(gold)

# Method to learn a new skill
func learn_skill(skill: Skill):
	print("Learning skill: ", skill.name)
	if skill.is_passive:
		skill.apply_passive_effect(self)
	else:
		active_skills.append(skill)
	print("Skill learned: ", skill.name)

# Stun the character for a duration
func stun(duration: float) -> void:
	if is_stunned:
		return
	is_stunned = true
	print("Character stunned for", duration, "seconds.")
	velocity = Vector2.ZERO
	stun_timer.start()
	stun_timer.wait_time = duration

func stunned():
	if is_stunned == true:
		target.sprite.modulate = Color(1,0,0)
		print("stuned ", target)

# Called when stun duration ends
func _on_stun_end() -> void:
	is_stunned = false
	print("Stun ended.")
	target.sprite.modulate = Color(1,1,1)

var is_invincible: bool = false
var invincibility_timer: Timer = null

func set_invincible(duration: float) -> void:
	is_invincible = true
	print(name, "is now invincible for", duration, "seconds.")
	if not invincibility_timer:
		invincibility_timer = Timer.new()
		invincibility_timer.one_shot = true
		add_child(invincibility_timer)
	invincibility_timer.wait_time = duration
	invincibility_timer.start()
	invincibility_timer.connect("timeout", Callable(self, "_end_invincibility"))

func _end_invincibility() -> void:
	is_invincible = false
	self.sprite.modulate = Color(1,1,1)
	print(name, "is no longer invincible.")

func find_target_and_attack():
	if is_stunned:
		return

	target = find_nearest_target("Enemies")
	if target:
		var direction = (target.global_position - global_position).normalized()
		if global_position.distance_to(target.global_position) > attack_range:
			velocity = direction * move_speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			if attack_timer.is_stopped():
				attack(target)
	else:
		velocity = Vector2.ZERO

func _process(delta: float):
	find_target_and_attack()
