#manager.gd
extends Panel

enum MODE {
	INVENTORY,
	SHOP
}

var currency: int = 100

@onready var balance_label: Label = %Balance

func _ready():
	_update_balance_ui()

func _input(event):
	if event.is_action_pressed("inventory"):
		open_mode(MODE.INVENTORY)


func open_mode(mode):
	visible = not visible

	match mode:
		MODE.INVENTORY:
			%Shop.visible = false
			if visible:
				print("Inventory mode.")

		MODE.SHOP:
			%Shop.visible = true
			if visible:
				print("Shop mode.")

func _update_balance_ui():
	if balance_label:
		balance_label.text = "Gold: " + str(currency)
 
