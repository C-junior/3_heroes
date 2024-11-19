# healing_light.gd
extends Skill

@export var heal_percentage: float = 0.2  # 20% of max health
@export var healing_effect_scene: PackedScene = preload("res://Skills/Cleric/healing_light_effect.tscn")  # Healing visual effect scene

var cooldown_timer: Timer = null

func init(character: BaseCharacter) -> void:
	print("init healing light")
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_healing_light(character)
	cooldown_timer.start()

func _trigger_healing_light(character: BaseCharacter) -> void:
	var ally = character.find_injured_ally()
	if ally:
		var heal_amount = ally.get_max_health() * heal_percentage
		ally.receive_heal(heal_amount)
		print("Healing Light healed ", ally.name, " for ", heal_amount)

		# Create the healing visual effect above the healed ally
		var healing_effect = healing_effect_scene.instantiate() as Node2D
		healing_effect.global_position = ally.global_position + Vector2(0, -20)  # Position slightly above the ally
		ally.get_parent().add_child(healing_effect)  # Add to ally's parent to follow game structure

func _on_cooldown_ready():
	print("Healing Light is ready again!")
