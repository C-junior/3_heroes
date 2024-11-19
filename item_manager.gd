# item_manager
extends Node
class_name ItemManager

var items = ItemDB

func equip_item_to_character(character: BaseCharacter, item: Item):
	if item and character.can_equip(item):
		character.equip_item(item)
		print(character.name, " equipped ", item.name)
	else:
		print("Item cannot be equipped by the character!")

func unequip_item_from_character(character: BaseCharacter, item: Item):
	character.unequip_item(item)
	print(character.name, " unequipped from ", item.name)
