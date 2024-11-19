# global.gd
extends Node
class_name Global

@export var currency: int = 0

# Cache reference to the balance label
@onready var balance_label: Label = get_node("/root/UI/Currency").get_child(1)


func _ready():
	currency = 100  # Initialize starting gold
	_update_balance_ui()

# Adds currency (gold) and updates the UI
func add_currency(amount: int):
	currency += amount
	_update_balance_ui()

# Function to update the balance label in the UI
func _update_balance_ui():
	if balance_label != null:
		balance_label.text = str(currency)
	else:
		print("Error: Balance label not found!")
