# big_shield.gd
extends Skill

@export var block_count: int = 3  # Block 3 attacks

var cooldown_timer: Timer = null

func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_big_shield(character)
	cooldown_timer.start()

func _trigger_big_shield(character: BaseCharacter) -> void:
	character.activate_shield(block_count)
	print("Big Shield activated, blocking", block_count, "attacks.")

func _on_cooldown_ready():
	print("Big Shield is ready again!")
