# goblin_assassin.gd
extends "res://Enemies/enemy.gd"

@export var stealth_duration: float = 2.0  # Time before appearing

func _ready() -> void:
	enemy_name = "Goblin Assassin"
	min_gold_reward = 30  # Minimum gold to drop
	max_gold_reward = 50 # Maximum gold to drop
	enemy_attack_damage = 80
	enemy_move_speed = 70
	goblin_max_health = 600

	# Delay appearance
	sprite.visible = false

	# Use an async function to wait for the timer
	await get_tree().create_timer(stealth_duration).timeout

	sprite.visible = true
	super._ready()
