extends BaseCharacter

@export var heal_amount: int = 40
@export var heal_cooldown: float = 2.0
@export var cleric_max_health: int = 1000

@onready var sprite = $ClericSprite

@onready var heal_timer = Timer.new()

# Skill-related variables
var cooldown_timers: Dictionary = {}


func _ready():
	character_type = constants.CharacterType.HEALER  # Clerics are Healers
	base_max_health = cleric_max_health
	current_health = base_max_health
	heal_timer.wait_time = heal_cooldown
	heal_timer.one_shot = true
	add_child(heal_timer)
	heal_timer.connect("timeout", Callable(self, "_on_heal_timeout"))
	health_progress_bar.max_value = cleric_max_health
	health_progress_bar.value = current_health
	add_to_group("PlayerCharacters")

func _process(delta: float):
	# Find nearest injured ally to heal
	var injured_ally = find_injured_ally()
	if injured_ally:
		move_and_heal(injured_ally, delta)
	use_skills()

func find_injured_ally() -> Node2D:
	var allies = get_tree().get_nodes_in_group("PlayerCharacters")
	var injured_ally: Node2D = null
	var lowest_health: int = cleric_max_health

	for ally in allies:
		if ally.get_health() < ally.get_max_health() and ally.get_health() < lowest_health:
			injured_ally = ally
			lowest_health = ally.get_health()

	return injured_ally

func move_and_heal(target: Node2D, delta: float):
	var direction = (target.global_position - global_position).normalized()
	if global_position.distance_to(target.global_position) > attack_range:
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if heal_timer.is_stopped():
			heal(target)

func heal(target: Node2D):
	if target.has_method("receive_heal"):
		target.receive_heal(heal_amount)
		heal_timer.start()  # Start heal cooldown

# Called when heal timer is done
func _on_heal_timeout():
	pass

# Learn a new skill and initialize it for the Cleric
func learn_skill(skill: Skill):
	learned_skills.append(skill)
	skill.init(self)  # Initialize skill for the Cleric instance
	_setup_skill_cooldown(skill)  # Set up cooldown for the skill
	print("Cleric learned skill: ", skill.name)

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
