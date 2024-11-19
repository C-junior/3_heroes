# defense_stance.gd
extends Skill

@export var defense_boost: int = 40  # Boost defense by 40%
@export var duration: float = 5  # Duration in seconds
var cooldown_timer: Timer = null
var duration_timer: Timer = null
var buff_active = false

# Initialize with character's timers
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	duration_timer = Timer.new()
	cooldown_timer.one_shot = true
	duration_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	duration_timer.wait_time = duration
	character.add_child(cooldown_timer)
	character.add_child(duration_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_defense_stance_ready"))
	duration_timer.connect("timeout", Callable(self, "_reset_defense").bind(character))

# Override the apply_effect method
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	character.defense += defense_boost
	print("Defense Stance activated: Defense +", defense_boost ," and its ", character.defense)
	buff_active = true
	cooldown_timer.start()
	duration_timer.start()
	print("buff ativo ", buff_active)

func _reset_defense(character: BaseCharacter) -> void:
	# Revert defense boost after duration ends
	if not buff_active:
		character.defense -= defense_boost
		buff_active = false
		print("Defense Stance ended: Defense -", defense_boost, "and was ", character.defense)
		print("buff ativo ", buff_active)
	else: 
		print("Defense Stance ended and doesnt nothing: Defense -", defense_boost, "and was ", character.defense)
		print("buff ativo ", buff_active)
func _on_defense_stance_ready():
	print("Defense Stance is ready again!")
