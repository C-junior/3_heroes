extends Skill

@export var attack_speed_increase: float = 0.2  # 20% attack speed boost
@export var buff_duration: float = 5.0  # Buff lasts for 5 seconds
var cooldown_timer: Timer = null

# Initialize cooldown and buff timer
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	# Apply the attack speed buff
	character.attack_speed += attack_speed_increase
	character.modulate = Color(1, 1, 0)  # Change color to indicate buff
	#Timer.new().start(buff_duration).connect("timeout", Callable(self, "_reset_attack_speed").bind(character))
	cooldown_timer.start()

func _reset_attack_speed(character: BaseCharacter) -> void:
	character.attack_speed -= attack_speed_increase  # Revert attack speed
	character.modulate = Color(1, 1, 1)  # Revert color

func _on_cooldown_ready():
	print("Valkyrie's Zeal is ready again!")
