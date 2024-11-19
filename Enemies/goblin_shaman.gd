# goblin_shaman.gd
extends "res://Enemies/enemy.gd"

@export var magic_attack_damage: int = 35
@export var shaman_attack_range: float = 350.0  # Range for casting spells

func _ready():
	enemy_name = "Goblin Shaman"
	min_gold_reward = 20  # Minimum gold to drop
	max_gold_reward = 45 # Maximum gold to drop
	enemy_attack_damage = magic_attack_damage
	enemy_move_speed = 50
	goblin_max_health = 800
	attack_range = shaman_attack_range
	super._ready()

# Override the default attack with a ranged magic attack
#func move_and_attack(target: Node, delta: float):
	#if global_position.distance_to(target.global_position) <= cast_range:
		## Implement magic casting effect here if needed
		##_shoot_magic_bolt(target)
		#target.take_damage(enemy_attack_damage)
	#else:
		## Approach the target if out of range
		#super.move_and_attack(target, delta)
func attack(target: Node2D):
	if target and target.has_method("take_damage"):
		_shoot_magic_bolt(target)
		attack_timer.start()

# Shoot a projectile towards the target
func _shoot_magic_bolt(target: Node2D):
	var magic_bolt = load("res://magic_bolt.tscn").instantiate()
	magic_bolt.position = global_position  # Start from the wizard's position
	var direction = (target.global_position - global_position).normalized()
	magic_bolt.set_direction(direction)
	magic_bolt.set_damage(attack_damage)  # Set the damage based on wizard's attack damage
	get_parent().add_child(magic_bolt)
	print("Shaman shot magic bolt at target:", target.name)
