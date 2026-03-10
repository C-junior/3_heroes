# goblin_brute.gd
extends "res://Enemies/enemy.gd"

func _ready():
	# Customize specific stats for Goblin Brute
	min_gold_reward = 10  # Minimum gold to drop
	max_gold_reward = 30 # Maximum gold to drop
	enemy_name = "Goblin Brute"
	enemy_attack_damage = 35
	enemy_move_speed = 30
	goblin_max_health = 300
	super._ready()  # Calls the _ready() function in enemy.gd to set up common logic
