# item_manager.gd
extends Node
class_name ItemManager

var item_database = preload("res://Assets/Items/ItemDatabase.gd").new()

func get_item(item_name: String) -> Item:
    return item_database.get_item(item_name)

func equip_item(character: BaseCharacter, item_name: String):
    var item = get_item(item_name)
    if item and character.can_equip(item):
        character.equip_item(item)
        print(character.name + " equipped " + item.name)
    else:
        print("Item " + item_name + " cannot be equipped by " + character.name)

func unequip_item(character: BaseCharacter, item_name: String):
    var item = get_item(item_name)
    if item:
        character.unequip_item(item)
        print(character.name + " unequipped " + item.name)
