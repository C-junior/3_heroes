# meteor_strike.gd
extends Skill

@export var damage: int = 300  # Single meteor damage
@export var meteor_scene: PackedScene = preload("res://Skills/Wizard/meteor_strike_area.tscn" )  # Meteor scene

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

	_trigger_meteor_strike(character)
	cooldown_timer.start()

func _trigger_meteor_strike(character: BaseCharacter) -> void:
	var target = character.find_nearest_target("Enemies")
	if not target:
		return  # No target found

	var meteor = meteor_scene.instantiate() as Area2D
	meteor.position = target.global_position + Vector2(0, -500)  # Start 500 pixels above the target
	meteor.target_position = target.global_position               # Set the impact position
	meteor.damage = damage
	character.get_parent().add_child(meteor)
	print("Meteor Strike activated at", target.global_position)

func _on_cooldown_ready():
	print("Meteor Strike is ready again!")
