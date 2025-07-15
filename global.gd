# global.gd
extends Node
class_name Global

@export var currency: int = 0

func _ready():
	currency = 100  # Initialize starting gold

# Adds currency (gold)
func add_currency(amount: int):
	currency += amount
