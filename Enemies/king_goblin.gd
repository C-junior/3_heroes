
# king_goblin.gd
extends "res://Enemies/enemy.gd"

@export var king_goblin_max_health: int = 5000  # Higher health for the boss
@export var king_goblin_attack_damage: int = 100  # Stronger attack
@export var summon_cooldown: float = 10.0  # Time between minion summons
@export var area_attack_radius: float = 150.0  # Radius for the area attack
@export var area_attack_damage: int = 150  # Damage for area attack
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


@onready var summon_timer = Timer.new()
@onready var area_attack_timer = Timer.new()
# Variable to track enraged state
var is_enraged: bool = false

func _ready():
	attack_damage = king_goblin_attack_damage
	current_health = king_goblin_max_health
	health_progress_bar.max_value = king_goblin_max_health
	health_progress_bar.value = current_health
	move_speed = enemy_move_speed * 0.7
	add_to_group("Enemies")

	# Set up summon and area attack timers
	summon_timer.wait_time = summon_cooldown
	summon_timer.one_shot = false
	add_child(summon_timer)
	summon_timer.timeout.connect(_summon_minions)
	summon_timer.start()

	area_attack_timer.wait_time = 8.0
	area_attack_timer.one_shot = false
	add_child(area_attack_timer)
	area_attack_timer.timeout.connect(_perform_area_attack)
	area_attack_timer.start()
	
	# Increase the collision shape size for the King Goblin
	var shape = collision_shape.shape
	shape.height *= 1.5
	shape.radius *= 1.5

func _summon_minions():
	var goblin_scene = preload("res://Enemies/goblin.tscn")
	for i in range(2):  # Summon two minions each time
		var minion = goblin_scene.instantiate() as Node2D
		minion.position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		get_parent().add_child(minion)
	print("King Goblin summoned minions!")

func _perform_area_attack():
	var players_in_radius = get_tree().get_nodes_in_group("PlayerCharacters")
	for player in players_in_radius:
		var distance = global_position.distance_to(player.global_position)
		if distance <= area_attack_radius:
			if player.has_method("take_damage"):
				player.take_damage(area_attack_damage)
				print("King Goblin dealt area attack to:", player.name)


# Override take_damage to add enraged state when low on health
func take_damage(damage: int):
	
	super.take_damage(damage)
	print("King Goblin took", damage, "damage, remaining health:", current_health)

	# Trigger enraged state when health is below 30%
	if current_health < king_goblin_max_health * 0.3 and !is_enraged:
		_become_enraged()
func _become_enraged():
	is_enraged = true
	attack_damage *= 1.5
	move_speed *= 1.3
	print("King Goblin is now enraged! Increased attack and speed.")
