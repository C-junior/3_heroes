# goblin_berserker.gd
extends "res://Enemies/enemy.gd"

@export var frenzy_chance: float = 0.25  # 25% chance to enter frenzy
var is_in_frenzy: bool = false
@export var stealth_duration: float = 3.0  # Time before appearing

func _ready():
	enemy_name = "Goblin Berserker"
	min_gold_reward = 15  # Minimum gold to drop
	max_gold_reward = 40 # Maximum gold to drop
	enemy_attack_damage = 60
	enemy_move_speed = 60
	goblin_max_health = 1000
	super._ready()

func _process(delta):
	# Trigger frenzy mode with a chance
	if !is_in_frenzy and randi() % 100 < frenzy_chance * 100:
		is_in_frenzy = true
		enemy_attack_damage *= 2
		enemy_move_speed *= 1.5
		await get_tree().create_timer(stealth_duration).timeout # Frenzy lasts for 3 seconds
		enemy_attack_damage /= 2
		enemy_move_speed /= 1.5
		is_in_frenzy = false
	
	super._process(delta)  # Process regular enemy behavior
