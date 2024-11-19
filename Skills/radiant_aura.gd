# radiant_aura.gd
extends Skill

@export var regen_amount: int = 5  # Amount healed per tick
@export var regen_duration: float = 5.0  # Total duration of regen effect
@export var radiant_aura_effect_scene: PackedScene = preload("res://Skills/Cleric/radiant_aura_effect.tscn")  # Aura effect scene

var cooldown_timer: Timer = null
var regen_timer: Timer = null
var heal_ticks: int = 0

# Initialize cooldown and regen timers
func init(character: BaseCharacter) -> void:
	# Cooldown timer for the skill
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

	# Regen timer to apply healing every second
	regen_timer = Timer.new()
	regen_timer.wait_time = 1.0  # Heal once per second
	regen_timer.one_shot = false
	character.add_child(regen_timer)
	regen_timer.connect("timeout", Callable(self, "_apply_heal_tick").bind(character))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_radiant_aura(character)
	cooldown_timer.start()

func _trigger_radiant_aura(character: BaseCharacter) -> void:
	print("Radiant Aura activated!")

	# Create the visual effect and position it at the character’s location
	var aura_effect = radiant_aura_effect_scene.instantiate() as Area2D
	
	character.add_child(aura_effect)

	# Start healing over time
	heal_ticks = 0
	regen_timer.start()

# Called each second to heal all allies within range
func _apply_heal_tick(character: BaseCharacter) -> void:
	heal_ticks += 1
	
	# Heal all allies in the PlayerCharacters group
	var allies = character.get_tree().get_nodes_in_group("PlayerCharacters")
	for ally in allies:
		ally.receive_heal(regen_amount)
		print("Radiant Aura healed", ally.name, "for", regen_amount, "HP on tick", heal_ticks)

	# Stop healing after the specified duration
	if heal_ticks >= regen_duration:
		regen_timer.stop()
		print("Radiant Aura healing complete.")

func _on_cooldown_ready():
	print("Radiant Aura is ready again!")
