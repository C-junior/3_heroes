# interaction.gd
extends Area2D

var can_interact = false:
	set(value):
		can_interact = value

func _on_body_entered(body: Node2D) -> void:
	can_interact = true

func _on_body_exited(body: Node2D) -> void:
	can_interact = false

func interaction():
	if can_interact:
		var knight = get_tree().current_scene.find_child("Knight")
		if knight and knight is BaseCharacter:
			# Trigger item interaction or equip action
			knight.equip(knight.current_item)
			print(knight.name + " equipped " + knight.current_item.name)
