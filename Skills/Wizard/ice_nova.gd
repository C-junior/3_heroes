# ice_nova.gd
extends Skill

@export var damage: int = 182  # Base damage of the Ice Nova
@export var slow_duration: float = 2.0  # Duration enemies are slowed
@export var slow_percentage: float = 0.5  # 50% speed reduction
@export var effect_radius: float = 350.0  # Radius of the Ice Nova
@export var ice_nova_scene: PackedScene = preload("res://Skills/Wizard/ice_nova.tscn")

var cooldown_timer: Timer = null

func init(character: BaseCharacter) -> void:
	# Initialize the cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_on_cooldown_ready)

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is still in cooldown

	_trigger_ice_nova(character)
	cooldown_timer.start()

func _trigger_ice_nova(character: BaseCharacter) -> void:
	var target = character.find_nearest_target("Enemies")
	if not target:
		return  # No target found

	var ice_nova = ice_nova_scene.instantiate() as Area2D
	ice_nova.position = character.target.global_position
	ice_nova.damage = damage
	ice_nova.slow_percentage = slow_percentage	
	ice_nova.slow_duration = slow_duration
	character.get_parent().add_child(ice_nova)  # Add Ice Nova to the game scene
	target.slow(slow_duration)
	print("Ice Nova activated at", character.target.global_position)

func _on_cooldown_ready():
	print("Ice Nova is ready again!")
