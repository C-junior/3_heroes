# item_manager.gd
extends Node
class_name ItemManager

# Manages item equipment for characters

func equip_item_to_character(character: BaseCharacter, item: Item) -> void:
	if character == null or item == null:
		print("Invalid character or item for equipment")
		return
	
	# Check if character can equip this item
	if not _can_character_equip_item(character, item):
		print("Character cannot equip this item type")
		return
	
	# Determine which slot the item goes to
	var slot_name = _get_slot_for_item_type(item.type)
	if slot_name == "":
		return
	
	# Unequip current item in that slot if any
	if character.equipped_items.has(slot_name) and character.equipped_items[slot_name] != null:
		unequip_item_from_character(character, character.equipped_items[slot_name])
	
	# Equip the new item
	character.equipped_items[slot_name] = item
	
	# Apply item stats
	_apply_item_stats(character, item)
	
	print(character.name, " equipped ", item.name)

func unequip_item_from_character(character: BaseCharacter, item: Item) -> void:
	if character == null or item == null:
		return
	
	# Remove item stats
	_remove_item_stats(character, item)
	
	# Remove from equipped items
	for slot_name in character.equipped_items.keys():
		if character.equipped_items[slot_name] == item:
			character.equipped_items[slot_name] = null
			break
	
	print(character.name, " unequipped ", item.name)

func _can_character_equip_item(character: BaseCharacter, item: Item) -> bool:
	if item.allowed_types.is_empty():
		return true  # No restrictions
	
	return item.allowed_types.has(character.character_type)

func _get_slot_for_item_type(type: String) -> String:
	match type:
		"weapon":
			return "weapon"
		"armor":
			return "armor"
		"accessory":
			return "accessory"
		_:
			print("Unknown item type: ", type)
			return ""

func _apply_item_stats(character: BaseCharacter, item: Item) -> void:
	character.base_attack_damage += item.attack_bonus
	character.base_defense += item.defense_bonus
	character.base_max_health += item.health_bonus
	character.base_move_speed += item.speed_bonus
	character.attack_range += item.range_bonus
	
	# Update current stats
	character.update_stats()

func _remove_item_stats(character: BaseCharacter, item: Item) -> void:
	character.base_attack_damage -= item.attack_bonus
	character.base_defense -= item.defense_bonus
	character.base_max_health -= item.health_bonus
	character.base_move_speed -= item.speed_bonus
	character.attack_range -= item.range_bonus
	
	# Update current stats
	character.update_stats()
