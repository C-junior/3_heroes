# haste.gd
extends Skill

@export var cooldown_reduction_percentage: float = 0.2  # 20% faster cooldowns

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
	_trigger_haste(character)
	cooldown_timer.start()

# Reduce cooldowns of all skills
func _trigger_haste(character: BaseCharacter) -> void:
	for skill in character.learned_skills:
		if skill.cooldown > 0:
			skill.cooldown *= (1 - cooldown_reduction_percentage)
	print("Haste applied! Cooldowns reduced.")

func _on_cooldown_ready():
	print("Haste is ready again!")
