extends GridContainer


func equip(item):
	get_tree().current_scene.find_child("knight").current_item = item
