# valkyrie.gd
extends BaseCharacter

# Valkyrie-specific stats
@export var valkyrie_attack_damage: int = 70
@export var valkyrie_defense: int = 8
@export var valkyrie_move_speed: int = 85
@export var valkyrie_max_health: int = 350
@export var valkyrie_attack_cooldown: float = 1.2
@onready var sprite: AnimatedSprite2D = $ValkyrieSprite

# Skill-related variables
var cooldown_timers: Dictionary = {}

@export var current_item: Item:
	set(value):
		current_item = value
		print("current item valk? ", current_item)
		if current_item != null:
			valkyrie_attack_damage += current_item.attack_bonus 

# Initialize the Valkyrie
func _ready():
	base_max_health = valkyrie_max_health
	base_attack_damage = valkyrie_attack_damage
	base_defense = valkyrie_defense
	base_move_speed = valkyrie_move_speed
	current_health = base_max_health
	current_item = null  # Start without any item equipped
	character_type = constants.CharacterType.VALKYRIE
	health_progress_bar.max_value = base_max_health  # Set max value for the progress bar
	health_progress_bar.value = current_health  # Initialize progress bar value

	attack_timer.wait_time = valkyrie_attack_cooldown  # Attack timer setup
	attack_timer.start()  # Start the timer
	update_stats()
	
	add_to_group("PlayerCharacters")
	update_level_ui()
	learned_skills = []

# Valkyrie-specific weapon restrictions
#func can_equip(item: Item) -> bool:
	## Valkyries can equip spears and swords
	#if item.name == "Spear" or item.name == "Iron Sword":
		#return true
	#return false

# Learn a new skill and initialize it for the Cleric
func learn_skill(skill: Skill):
	learned_skills.append(skill)
	skill.init(self)  # Initialize skill for the Cleric instance
	_setup_skill_cooldown(skill)  # Set up cooldown for the skill
	print("Valkyrie learned skill: ", skill.name)

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
	sprite.modulate = Color(1, 1, 1)  # Reset color when the skill is ready

# Trigger the skill and start cooldown
func use_skills():
	for skill in learned_skills:
		if cooldown_timers.has(skill) and cooldown_timers[skill].is_stopped():
			skill.apply_effect(self)  # Apply the skill effect
			cooldown_timers[skill].start()  # Start the cooldown timer after using the skill
			print("Skill used:", skill.name)

func _process(delta: float):
	# Find nearest enemy to attack
	target = find_nearest_target("Enemies")
	if target:
		move_and_attack(target, delta)
	
	use_skills()
