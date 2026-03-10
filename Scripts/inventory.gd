# inventory.gd
extends GridContainer
class_name Inventory

@onready var slots = get_children()

@onready var constant = constants

# Ensure that the correct item type is added to the correct slot.
func add_item(item: Item):
	var allowed_type_names = []
	var joined_names = ""
	for slot in slots:
		if slot.item == null:
			slot.item = item
		# Build the allowed character types string
			for allowed_type in item.allowed_types:
				allowed_type_names.append(constant.character_type_names[allowed_type])

					# Create a string manually			
				for name in allowed_type_names:
					if joined_names != "":
						joined_names += ", "
					joined_names += name

			# Build tooltip with dynamic attributes
			var tooltip_text = "Nome: %s\n Preço: %s\n Equipável em: %s\nAtributos:\n" % [item.name, item.price, joined_names]

			# Dynamically append item stats if they are non-zero
			if item.attack_bonus != 0:
				var color = "+ " if item.attack_bonus > 0 else "  "
				tooltip_text += "  ATK: %s%d\n" % [color, item.attack_bonus]
					
			if item.defense_bonus != 0:
				var color = "+ " if item.defense_bonus > 0 else "  "
				tooltip_text += "  DEF: %s%d\n" % [color, item.defense_bonus]
				
			if item.speed_bonus != 0:
				var color = "+ " if item.speed_bonus > 0 else "  "
				tooltip_text += "  SPD: %s%d\n" % [color, item.speed_bonus]
				
			if item.health_bonus != 0:
				var color = "+ " if item.health_bonus > 0 else "  "
				tooltip_text += "  HP: %s%d\n" % [color, item.health_bonus]

			# Show attack cooldown modifier as attack speed in percentage if different from 1.0
			if item.attack_cooldown_modifier != 1.0:
				var attack_speed = int((1.0 - item.attack_cooldown_modifier) * 100)
				var color = "+ " if attack_speed > 0 else "  "
				tooltip_text += "  Attack Speed: %s%d\n" % [color, attack_speed]

			slot.tooltip_text = tooltip_text
			return



func remove_item(item: Item):
	for slot in slots:
		if slot.item == item:
			slot.item = null
			return



#func equip_item_to_character(character: BaseCharacter, item: Item):	
	#if character and item:
		#character.equip_item(item)
		#
