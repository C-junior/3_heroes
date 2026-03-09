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

# Initialize the Valkyrie
func _ready():
	base_max_health = valkyrie_max_health
	base_attack_damage = valkyrie_attack_damage
	base_defense = valkyrie_defense
	base_move_speed = valkyrie_move_speed
	base_attack_cooldown = valkyrie_attack_cooldown
	character_type = Constants.CharacterType.VALKYRIE
	super._ready()
	add_to_group("PlayerCharacters")

# Valkyrie-specific weapon restrictions
#func can_equip(item: Item) -> bool:
	## Valkyries can equip spears and swords
	#if item.name == "Spear" or item.name == "Iron Sword":
		#return true
	#return false

# Learn a new skill and initialize it for the Cleric
func learn_skill(skill: Skill):
	super.learn_skill(skill)
	skill.init(self)  # Initialize skill for the Cleric instance
	if not skill.is_passive:
		_setup_skill_cooldown(skill)
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
	for skill in active_skills:
		if cooldown_timers.has(skill) and cooldown_timers[skill].is_stopped():
			skill.apply_effect(self)  # Apply the skill effect
			cooldown_timers[skill].start()  # Start the cooldown timer after using the skill
			print("Skill used:", skill.name)

func _process(delta: float):
	if is_dead:
		return
	# Find nearest enemy to attack
	find_target_and_attack()
	
	use_skills()
