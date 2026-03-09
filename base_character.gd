# base_character.gd
extends CharacterBody2D
class_name BaseCharacter

@export var character_type: int = Constants.CharacterType.FIGHTER  # Default character type

@onready var health_label = $HP
@onready var health_progress_bar = $HealthProgressBAr
@onready var popuploc = $PopupLocation
@onready var level_label: Label = $LevelLabel
@onready var attack_timer: Timer = $Timer
@onready var level_system: LevelSystem = $LevelSystem
@onready var skill_name_location: Marker2D = $SkillNameLocation
@export var lifesteal_percentage: float = 0.0  # Percentage of damage converted to health

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

# Equipment system
var equipped_items: Dictionary = {
	"weapon": null,
	"armor": null,
	"accessory": null
}

var current_health: int
var target: Node2D  # Current attack target
var is_dead: bool = false  # Track death state for resurrection

# Reference to the level system
signal level_up_skill_popup
signal hero_died(character: BaseCharacter)

func _ready():
	learned_skills = []
	active_skills = []
	current_health = max_health
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	if not attack_timer.is_connected("timeout", Callable(self, "_on_attack_timeout")):
		attack_timer.connect("timeout", Callable(self, "_on_attack_timeout"))

	# Initialize stats and connect level-up signals
	update_stats()
	if not level_system.is_connected("leveled_up", Callable(self, "_on_leveled_up")):
		level_system.connect("leveled_up", Callable(self, "_on_leveled_up"))
	update_level_ui()

	# Initialize stun timer
	stun_timer.one_shot = true
	if not stun_timer.is_connected("timeout", Callable(self, "_on_stun_end")):
		stun_timer.connect("timeout", Callable(self, "_on_stun_end"))
	add_child(stun_timer)

# Update stats based on equipped items
func update_stats():
	var effective_level = max(level_system.level - 1, 0)
	attack_damage = base_attack_damage + (damage_growth * effective_level)
	defense = base_defense + (defense_growth * effective_level)
	move_speed = base_move_speed
	attack_cooldown = base_attack_cooldown
	max_health = base_max_health + (health_growth * effective_level)
	attack_timer.wait_time = attack_cooldown

	for skill in learned_skills:
		if skill != null and skill.is_passive:
			attack_damage += skill.attack_bonus
			defense += skill.defense_bonus
			max_health += skill.health_bonus
			
			if skill.attack_bonus > 0:
				print("Applied attack bonus from ", skill.name, ": ", skill.attack_bonus)
			if skill.defense_bonus > 0:
				print("Applied defense bonus from ", skill.name, ": ", skill.defense_bonus)
			if skill.health_bonus > 0:
				print("Applied health bonus from ", skill.name, ": ", skill.health_bonus)

	current_health = min(current_health, max_health)
	update_health_label()

# Update the health label UI
func update_health_label():
	health_label.text = str(current_health)
	health_progress_bar.max_value = max_health
	health_progress_bar.value = current_health

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
		_play_feedback(Color(0.35, 1.0, 0.55), 0.08)
		update_health_label()

# Handle taking damage
func take_damage(damage: int):
	if shield_active and arcane_shield_skill != null:
		damage = arcane_shield_skill.absorb_damage(damage, self)
	if is_invincible:
		var invincible_visual = get_visual_node()
		if invincible_visual:
			invincible_visual.modulate = Color(1, 1, 0)
		print(name, "is invincible and took no damage!")
		return
	if shield_block_count > 0:
		shield_block_count -= 1
		print("Blocked attack! Remaining blocks:", shield_block_count)
		if shield_block_count == 0:
			print("Shield has been broken!")
	else:
		var reduced_damage = max(damage - defense, 1)
		current_health -= reduced_damage
		popuploc.popup(-reduced_damage)
		update_health_label()
		_play_feedback(Color(1.0, 0.35, 0.35), 0.12)
		_shake_game_view(clamp(reduced_damage / 15.0, 2.0, 8.0))
		if current_health <= 0:
			die()

# Character dies — disable instead of removing so we can revive
func die():
	is_dead = true
	set_process(false)
	set_physics_process(false)
	visible = false
	# Move off-screen so collision doesn't interfere
	global_position = Vector2(-9999, -9999)
	emit_signal("hero_died", self)
	print(name, " has fallen!")

# Revive a dead hero at a given HP ratio
func revive(hp_ratio: float = 0.5):
	is_dead = false
	current_health = int(max_health * hp_ratio)
	set_process(true)
	set_physics_process(true)
	visible = true
	global_position = Vector2(100, 200)  # Respawn position
	update_health_label()
	print(name, " has been revived with ", current_health, " HP!")

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
	_play_feedback(Color(0.35, 1.0, 0.55), 0.1)
	update_health_label()

# Handle level-up and stat growth
func _on_leveled_up():
	update_stats()
	current_health = max_health
	update_health_label()
	update_level_ui()

# Update the level label UI
func update_level_ui():
	level_label.text = name + " Lv: " + str(level_system.level)

# Adds XP to all party characters
func add_xp_to_party(amount: int):
	for player in get_tree().get_nodes_in_group("PlayerCharacters"):
		player.level_system.add_xp(amount)

# Add global gold when enemy dies
func add_gold(gold: int):
	global.add_currency(gold)

# Method to learn a new skill
func learn_skill(skill: Skill):
	print("Learning skill: ", skill.name)
	# Always add to learned skills so we can track bonuses
	learned_skills.append(skill)
	_announce_skill(skill.name)
	
	if skill.is_passive:
		skill.apply_passive_effect(self)
		# Trigger a stat update immediately for passives
		update_stats()
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
	stun_timer.wait_time = duration
	stun_timer.start()

func stunned():
	if is_stunned == true:
		target.sprite.modulate = Color(1,0,0)
		print("stuned ", target)

# Called when stun duration ends
func _on_stun_end() -> void:
	is_stunned = false
	print("Stun ended.")
	var visual = get_visual_node()
	if visual:
		visual.modulate = Color(1, 1, 1)

var is_invincible: bool = false
var invincibility_timer: Timer = null

func set_invincible(duration: float) -> void:
	is_invincible = true
	print(name, "is now invincible for", duration, "seconds.")
	if not invincibility_timer:
		invincibility_timer = Timer.new()
		invincibility_timer.one_shot = true
		add_child(invincibility_timer)
		invincibility_timer.connect("timeout", Callable(self, "_end_invincibility"))
	invincibility_timer.wait_time = duration
	invincibility_timer.start()

func _end_invincibility() -> void:
	is_invincible = false
	var visual = get_visual_node()
	if visual:
		visual.modulate = Color(1, 1, 1)
	print(name, "is no longer invincible.")

func get_visual_node() -> CanvasItem:
	var visual = get("sprite")
	if visual is CanvasItem:
		return visual
	return null

func find_target_and_attack():
	if is_stunned:
		velocity = Vector2.ZERO
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
	if is_dead:
		return
	find_target_and_attack()

func recover_between_waves(heal_ratio: float = 0.2):
	if current_health <= 0:
		return
	receive_heal(int(max_health * heal_ratio))

func _on_timer_timeout():
	_on_attack_timeout()

func _announce_skill(skill_name: String):
	if skill_name_location and skill_name_location.has_method("popup"):
		skill_name_location.popup(skill_name)

func _play_feedback(flash_color: Color, punch: float):
	var visual = get_visual_node()
	if visual == null:
		return
	visual.modulate = flash_color
	visual.scale = Vector2.ONE * (1.0 + punch)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.14)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.14)

func _shake_game_view(intensity: float):
	var main_game = get_tree().current_scene.get_node_or_null("MainGame")
	if main_game and main_game.has_method("trigger_screen_shake"):
		main_game.trigger_screen_shake(intensity)
