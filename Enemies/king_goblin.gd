
# king_goblin.gd
extends "res://Enemies/enemy.gd"

@export var king_goblin_max_health: int = 5000
@export var king_goblin_attack_damage: int = 100
@export var summon_cooldown: float = 10.0
@export var area_attack_radius: float = 150.0
@export var area_attack_damage: int = 150
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@onready var summon_timer = Timer.new()
@onready var area_attack_timer = Timer.new()
var is_enraged: bool = false

func _ready():
	# Apply wave scaling to boss stats
	enemy_name = "King Goblin"
	enemy_attack_damage = int(king_goblin_attack_damage * dmg_multiplier)
	goblin_max_health = int(king_goblin_max_health * hp_multiplier)
	enemy_move_speed = 30
	min_gold_reward = 50
	max_gold_reward = 100
	
	# Also scale area attack
	area_attack_damage = int(area_attack_damage * dmg_multiplier)
	
	super._ready()

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
	
	# Increase collision for boss
	if collision_shape and collision_shape.shape:
		var shape = collision_shape.shape
		shape.height *= 1.5
		shape.radius *= 1.5

func _summon_minions():
	var goblin_scene = preload("res://Enemies/goblin.tscn")
	for i in range(2):
		var minion = goblin_scene.instantiate() as Node2D
		minion.position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		# Apply some scaling to summoned minions too
		if minion.has_method("apply_wave_scaling"):
			minion.apply_wave_scaling(hp_multiplier * 0.5, dmg_multiplier * 0.5)
		get_parent().add_child(minion)

func _perform_area_attack():
	var players_in_radius = get_tree().get_nodes_in_group("PlayerCharacters")
	for player in players_in_radius:
		var distance = global_position.distance_to(player.global_position)
		if distance <= area_attack_radius:
			if player.has_method("take_damage"):
				player.take_damage(area_attack_damage)

func take_damage(damage: int):
	super.take_damage(damage)
	# Enrage at 30% HP
	if current_health < max_health * 0.3 and !is_enraged:
		_become_enraged()

func _become_enraged():
	is_enraged = true
	attack_damage = int(attack_damage * 1.5)
	move_speed = int(move_speed * 1.3)
	print("King Goblin is now ENRAGED!")
