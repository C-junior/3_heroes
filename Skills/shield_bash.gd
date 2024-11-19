extends Skill

@export var stun_duration: float = 2.0  # Stun for 2 seconds
@export var damage_percentage: float = 1.0  # 100% attack damage

var cooldown_timer: Timer = null  # Initialize timer variable

func init(character: BaseCharacter) -> void:
	if cooldown_timer == null:
		cooldown_timer = Timer.new()  # Create a new Timer
		cooldown_timer.one_shot = true
		cooldown_timer.wait_time = cooldown  # Set cooldown duration for the skill
		character.add_child(cooldown_timer)  # Add the timer as a child of the character
		cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))  # Connect the timeout signal

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown, so don't use it again

	_trigger_shield_bash(character)
	cooldown_timer.start()  # Start the cooldown timer

func _trigger_shield_bash(character: BaseCharacter) -> void:
	var target = character.find_nearest_target("Enemies")
	if target and target.has_method("take_damage"):
		target.take_damage(character.attack_damage * damage_percentage)
		target.stun(stun_duration)  # Apply stun to the target
		print("Shield Bash hit and stunned:", target.name, " by ", stun_duration)

func _on_cooldown_ready():
	print("Shield Bash is ready again!")
