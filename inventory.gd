# inventory.gd
# Note: This script might not be needed if inventory is just a GridContainer in the UI
# The inventory management is handled by the UI and Slot scripts

# If you need this as a separate class, you should:
# 1. Create an Inventory.tscn scene with this script
# 2. Instance it in the UI scene
# 3. Replace the GridContainer named "Inventory" with this scene

extends PanelContainer
class_name Inventory

@onready var slots_container = $Slots  # Container holding the slot nodes

var active_character: BaseCharacter = null

func _ready():
	# Connect to the UI's character switch signal
	if has_node("/root/Game/UI"):
		var ui = get_node("/root/Game/UI")
		if ui:
			ui.connect("character_switched", Callable(self, "_on_character_switched"))

func _on_character_switched(character: BaseCharacter):
	active_character = character
	update_inventory_display()

func update_inventory_display():
	if active_character == null:
		return
	
	# Update all slots based on character's equipped items
	for slot in slots_container.get_children():
		if slot is Slot:
			match slot.slot_type:
				Slot.SlotType.WEAPON:
					slot.item = active_character.equipped_items.get("weapon", null)
				Slot.SlotType.ARMOR:
					slot.item = active_character.equipped_items.get("armor", null)
				Slot.SlotType.ACCESSORY:
					slot.item = active_character.equipped_items.get("accessory", null)
