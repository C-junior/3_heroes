# skill_name_location.gd
extends Marker2D

@export var skill_name_shout: PackedScene


func popup():
	var skill_name = skill_name_shout.instantiate()
	skill_name.position = global_position
	
	var get_direction =  Vector2(randf_range(-1,1), -randf()) * 16
	
	var tween = get_tree().create_tween()
	tween.tween_property(skill_name, "position", global_position + get_direction, 0.75 )
	get_tree().current_scene.add_child(skill_name)
	
	var pai = get_tree().current_scene.find_child("Knight")
	
	if pai.update_level_ui:
		var animation_player = skill_name.get_node("AnimationPlayer")  # Adjust the path if needed
	
		animation_player.play("popup")  # Play the skill animation
		print( "popup skill ", pai)
		
