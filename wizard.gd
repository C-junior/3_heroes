# wizard.gd
extends BaseCharacter

@export var wizard_attack_damage: int = 62
@export var wizard_defense: int = 5
@export var wizard_move_speed: int = 50
@export var wizard_max_health: int = 200
@export var wizard_attack_range: float = 300.0
@onready var sprite: AnimatedSprite2D = $WizardSprite

@export var wizard_attack_cooldown: float = 2.0
@onready var items = ItemDB

# Skill-related variables
var cooldown_timers: Dictionary = {}

@onready var wizard_health_progress_bar = $HealthProgressBAr

@onready var itemDataBase = ItemDB

@export var current_item: Item:
	set(value):
		current_item = value
		if current_item != null:
			wizard_attack_damage += current_item.attack_bonus

func _ready():
	base_max_health = wizard_max_health
	base_attack_damage = wizard_attack_damage
	base_defense = wizard_defense
	attack_range = wizard_attack_range

	base_move_speed = wizard_move_speed
	current_health = base_max_health
	current_item = null  # Start without any item equipped

	character_type = constants.CharacterType.MAGE  # Wizards are Mages

	health_progress_bar.max_value = base_max_health  # Set max value for the progress bar
	health_progress_bar.value = current_health  # Initialize progress bar value


	attack_timer.wait_time = wizard_attack_cooldown
	attack_timer.start()
	update_stats()
	update_health_label()

	add_to_group("PlayerCharacters")
	learned_skills = []

# Learn a new skill and initialize its timers
func learn_skill(skill: Skill):
	learned_skills.append(skill)
	_setup_skill_cooldown(skill)
	skill.init(self)
	print("Learned skill:", skill.name)

# Set up cooldown timers for skills
func _setup_skill_cooldown(skill: Skill):
	if skill.cooldown > 0:
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = skill.cooldown
		cooldown_timers[skill] = timer
		add_child(timer)

# Called when a skill's cooldown finishes
func _on_skill_ready(skill: Skill):
	print("Skill ready again:", skill.name)

# Trigger the skill and start cooldown
func use_skills():
	for skill in learned_skills:
		if cooldown_timers.has(skill) and cooldown_timers[skill].is_stopped():
			skill.apply_effect(self)
			cooldown_timers[skill].start()

# Override the basic attack to include projectiles
func attack(target: Node2D):
	if target and target.has_method("take_damage"):
		_shoot_magic_bolt(target)
		attack_timer.start()

# Shoot a projectile towards the target
func _shoot_magic_bolt(target: Node2D):
	var magic_bolt = load("res://magic_bolt.tscn").instantiate()
	magic_bolt.position = global_position  # Start from the wizard's position
	var direction = (target.global_position - global_position).normalized()
	magic_bolt.set_direction(direction)
	magic_bolt.set_damage(attack_damage)  # Set the damage based on wizard's attack damage
	get_parent().add_child(magic_bolt)
	print("Wizard shot magic bolt at target:", target.name)

# Mana regeneration logic
func _process(delta: float):
	# Regenerate mana over time
	#wizard_mana = min(wizard_mana + mana_regen_rate * delta, 100)
	#mana_progress_bar.value = wizard_mana

	# Find nearest enemy to attack
	target = find_nearest_target("Enemies")
	if target:
		move_and_attack(target, delta)
	use_skills()
