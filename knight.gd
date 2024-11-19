# knight.gd
extends BaseCharacter

@onready var sprite = $KnightSprite

@export var knight_attack_damage: int = 85
@export var knight_defense: int = 1
@export var knight_move_speed: int = 60
@export var knight_max_health: int = 300
@export var knight_attack_cooldown: float = 1.0
@onready var items = ItemDB

# Skill-related variables
#var learned_skills: Array = []
var cooldown_timers: Dictionary = {}
var charge_skill: Skill = null  # Store the charge skill reference


@onready var knight_health_progress_bar = $HealthProgressBAr

@onready var itemDataBase = ItemDB

@export var current_item: Item:
	set(value):
		current_item = value
		print("current item knigr? ", current_item)
		if current_item != null:
			knight_attack_damage += current_item.attack_bonus 

func _ready():
	base_max_health = knight_max_health
	base_attack_damage = knight_attack_damage
	base_defense = knight_defense

	base_move_speed = knight_move_speed
	current_health = base_max_health
	current_item = null  # Start without any item equipped
	
	character_type = constants.CharacterType.FIGHTER  # Knights are Fighters
 
	health_progress_bar.max_value = base_max_health  # Set max value for the progress bar
	health_progress_bar.value = current_health  # Initialize progress bar value

	attack_timer.wait_time = knight_attack_cooldown  # Ensure attack_timer is initialized in BaseCharacter
	attack_timer.start()  # Start the timer
	update_stats()
	sprite.play("Idle")
	update_health_label()

	add_to_group("PlayerCharacters")
	# Initialize timers for skill usage
	learned_skills = []
	

# Learn a new skill and initialize its timers
func learn_skill(skill: Skill):
	learned_skills.append(skill)
	_setup_skill_cooldown(skill)
	print("Knight learned skill: ", skill.name)
	skill.init(self)  # Call init to initialize the skill properly (ensure cooldown_timer is initialized)
	print("all skills are ", learned_skills[0].name)
	# Initialize skill within the character context (call init)
	
	
	if skill.name == "Charge":
		charge_skill = skill

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
	sprite.modulate = Color(0,1,0)

# Trigger the skill and start cooldown
func use_skills():
	for skill in learned_skills:
		if cooldown_timers.has(skill) and cooldown_timers[skill].is_stopped():
			skill.apply_effect(self)  # Apply the skill effect
			cooldown_timers[skill].start()  # Start the cooldown timer after using the skill
			print("Skill used:", skill.name)
			sprite.modulate = Color(1,1,1)

# Update charge movement over time
func update_charge_movement(delta: float):
	if charge_skill != null:
		charge_skill.update_charge(delta, self)  # Call the charge update from the skill
		

func _process(delta: float):
	# Update charge movement if active
	update_charge_movement(delta)

	# Find nearest enemy to attack
	target = find_nearest_target("Enemies")
	if target:
		move_and_attack(target, delta)

	use_skills()
