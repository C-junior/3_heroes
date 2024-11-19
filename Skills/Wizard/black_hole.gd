# black_hole.gd
extends Skill

@export var damage_per_second: int = 50
@export var effect_radius: float = 200.0
@export var duration: float = 3.0
@export var black_hole_scene: PackedScene = preload("res://Skills/Wizard/black_hole_effect.tscn")

var cooldown_timer: Timer = null

func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_on_cooldown_ready)

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Skill is in cooldown

	_trigger_black_hole(character)
	cooldown_timer.start()

# Create and activate the black hole effect
func _trigger_black_hole(character: BaseCharacter) -> void:
	var target = character.find_nearest_target("Enemies")
	if not target:
		return  # No target found
	var black_hole = black_hole_scene.instantiate() as Area2D
	black_hole.position = target.global_position
	black_hole.damage_per_second = damage_per_second
	black_hole.effect_radius = effect_radius
	black_hole.duration = duration
	character.get_parent().add_child(black_hole)
	print("Black Hole activated by", character.name)

func _on_cooldown_ready():
	print("Black Hole is ready again!")
