# global.gd
extends Node

# This script is now a simple service locator for the GameStateManager.
# This is a temporary measure to avoid breaking the game while we refactor.
# The end goal is to remove this script entirely and use dependency injection.

var game_state_manager: GameStateManager

func _ready():
	game_state_manager = get_node("/root/GameStateManager")
	if game_state_manager == null:
		print("Error: GameStateManager not found!")

func get_game_state_manager() -> GameStateManager:
	return game_state_manager
