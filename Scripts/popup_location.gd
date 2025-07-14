# popup_location.gd
extends Marker2D

@export var damage_node: PackedScene

func popup(value: int):
	var showdamage = damage_node.instantiate()
	showdamage.position = global_position
	
	var get_direction =  Vector2(randf_range(-1,1), -randf()) * 16
	
	var tween = get_tree().create_tween()
	tween.tween_property(showdamage, "position", global_position + get_direction, 0.75 )	

	# Assuming the label is a child of showdamage
	var damage_label = showdamage.get_node("Label")  # Replace "Label" with the actual name of your label node
	damage_label.text = str(value)  # Set the damage text

	# Get the AnimationPlayer node
	var animation_player = showdamage.get_node("AnimationPlayer")  # Adjust the path if needed

	# Play the appropriate animation based on the value
	if value > 0:
		
		animation_player.play("popup_heal")  # Play healing animation
	else:
		animation_player.play("popup")  # Play damage animation
		
	get_tree().current_scene.add_child(showdamage)
