# game_state_manager.gd
extends Node
class_name GameStateManager

var currency: int = 0

func _ready():
    currency = 100  # Initialize starting gold

func add_currency(amount: int):
    currency += amount
