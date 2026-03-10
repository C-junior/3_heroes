# enemy.gd
extends BaseCharacter

@export var enemy_name: String = "Goblin"
@export var enemy_attack_damage: int = 28
@export var enemy_move_speed: int = 40
@export var goblin_max_health: int = 100
# sprite is inherited from BaseCharacter

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_reduction_rate: float = 200
var is_slowed: bool = false
var original_speed: int
var taunt_timer: Timer = null

# Wave scaling
var hp_multiplier: float = 1.0
var dmg_multiplier: float = 1.0

func _ready():
	sprite = $AnimatedSprite2D
	# Apply scaling
	var scaled_hp = int(goblin_max_health * hp_multiplier)
	var scaled_dmg = int(enemy_attack_damage * dmg_multiplier)
	
	attack_damage = scaled_dmg
	move_speed = enemy_move_speed
	original_speed = enemy_move_speed
	current_health = scaled_hp
	max_health = scaled_hp
	health_progress_bar.max_value = scaled_hp
	health_progress_bar.value = current_health
	add_to_group("Enemies")

	# Initialize taunt timer
	taunt_timer = Timer.new()
	taunt_timer.one_shot = true
	add_child(taunt_timer)
	taunt_timer.connect("timeout", Callable(self, "_on_taunt_end"))

# Called by wave_manager to scale enemy stats
func apply_wave_scaling(hp_mult: float, dmg_mult: float):
	hp_multiplier = hp_mult
	dmg_multiplier = dmg_mult

func _process(delta: float):
	# Try to find a player to attack first
	target = find_nearest_target("PlayerCharacters")
	
	if target:
		move_and_attack(target, delta)
	else:
		# No players alive — attack the base!
		_move_toward_base(delta)
	
	# Apply knockback
	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		move_and_slide()
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_reduction_rate * delta)

func _move_toward_base(delta: float):
	var base_nodes = get_tree().get_nodes_in_group("Base")
	if base_nodes.size() > 0:
		var base = base_nodes[0]
		var direction = (base.global_position - global_position).normalized()
		var dist = global_position.distance_to(base.global_position)
		if dist > 50:  # Move toward base
			velocity = direction * move_speed
			move_and_slide()
		else:
			# At base — deal damage
			velocity = Vector2.ZERO
			if attack_timer.is_stopped():
				_attack_base(base)

func _attack_base(base: Node):
	if base.has_method("take_damage"):
		base.take_damage(attack_damage)
		attack_timer.start()

# Apply knockback force
func knockback(force: Vector2) -> void:
	knockback_velocity = force

# Slow the enemy
func slow(duration: float):
	if not is_slowed:
		is_slowed = true
		move_speed /= 2
		sprite.modulate = Color(0, 0, 1)
		var timer = Timer.new()
		timer.wait_time = duration
		timer.one_shot = true
		add_child(timer)
		timer.start()
		await timer.timeout
		restore_speed()
		timer.queue_free()

func restore_speed():
	move_speed = original_speed
	sprite.modulate = Color(1, 1, 1)
	is_slowed = false

@export var xp_reward: int = 100
@export var min_gold_reward: int = 10
@export var max_gold_reward: int = 20

# Override death to use GameManager for rewards
func die():
	# Scale rewards slightly with wave
	var gold_bonus = int(max_gold_reward * hp_multiplier * 0.3)
	var random_gold = randi() % (max_gold_reward - min_gold_reward + 1) + min_gold_reward + gold_bonus
	
	# Grant gold through GameManager
	GameManager.add_gold(random_gold)
	
	# Grant XP to all player characters
	var xp_bonus = int(xp_reward * (1.0 + GameManager.get_prestige_bonus("xp_boost")))
	for player in get_tree().get_nodes_in_group("PlayerCharacters"):
		if player.has_method("add_xp_to_party"):
			player.add_xp_to_party(xp_bonus)
			break  # add_xp_to_party distributes to all
	
	queue_free()
