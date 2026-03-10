# global.gd
# Backwards compatibility wrapper — primary currency management moved to GameManager
extends Node
class_name Global

@export var currency: int = 0

func _ready():
	currency = GameManager.gold

# Adds currency (gold) via GameManager
func add_currency(amount: int):
	GameManager.add_gold(amount)
	currency = GameManager.gold

# Update balance UI (no longer relies on hardcoded node path)
func _update_balance_ui():
	currency = GameManager.gold
