extends Skill

@export var attack_boost: int = 30  # Boost attack by 30%
@export var defense_loss: int = 15  # Lose 15 defense
@export var duration: float = 5  # Duration in seconds
var cooldown_timer: Timer = null
var duration_timer: Timer = null

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
	cooldown_timer.connect("timeout", Callable(self, "_on_berserker_mode_ready"))
	duration_timer.connect("timeout", Callable(self, "_reset_stats").bind(character))

# Override the apply_effect method
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	character.attack_damage += attack_boost
	character.defense -= defense_loss
	print("Berserker Mode activated: Attack +", attack_boost, "Defense -", defense_loss)

	cooldown_timer.start()
	duration_timer.start()

func _reset_stats(character: BaseCharacter) -> void:
	character.attack_damage -= attack_boost
	character.defense += defense_loss
	print("Berserker Mode ended: Attack -", attack_boost, "Defense +", defense_loss)

func _on_berserker_mode_ready():
	print("Berserker Mode is ready again!")
