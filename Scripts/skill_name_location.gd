# skill_name_location.gd
extends Marker2D

@export var skill_name_shout: PackedScene

func popup(text: String):
	var skill_name = skill_name_shout.instantiate()
	skill_name.position = global_position
	skill_name.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var get_direction =  Vector2(randf_range(-1,1), -randf()) * 16
	
	var tween = get_tree().create_tween()
	tween.tween_property(skill_name, "position", global_position + get_direction, 0.75 )
	get_tree().current_scene.add_child(skill_name)
	var label = skill_name.get_node_or_null("Label")
	if label:
		label.text = text
	var animation_player = skill_name.get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("popup")
