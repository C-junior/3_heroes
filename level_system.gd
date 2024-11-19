# level_system.gd
extends Node
class_name LevelSystem

@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next_level: int = 100  # Initial XP required to level up
@export var gold_reward: int = 50  # Gold gained for killing an enemy

signal leveled_up

func add_xp(amount: int):
	xp += amount
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level_up()

func level_up():
	level += 1
	xp_to_next_level = int(xp_to_next_level * 2.5)  # Increase the XP needed for the next level
	emit_signal("leveled_up")
	print(xp_to_next_level, "necessario pro proximo lvl")

func get_gold_reward() -> int:
	return gold_reward
