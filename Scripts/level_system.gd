# level_system.gd
# Handles XP and leveling for individual units
extends Node
class_name LevelSystem

@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next_level: int = 80  # Reduced from 100 for faster early levels

signal leveled_up

func add_xp(amount: int):
	# Apply prestige XP boost
	var xp_bonus = GameManager.get_prestige_bonus("xp_boost")
	var boosted_amount = int(amount * (1.0 + xp_bonus))
	xp += boosted_amount
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level_up()

func level_up():
	level += 1
	# Gentler XP curve: ×1.8 instead of ×2.5 for better pacing
	xp_to_next_level = int(xp_to_next_level * 1.8)
	emit_signal("leveled_up")
	print("LEVEL UP! Now level ", level, " (next: ", xp_to_next_level, " XP)")
