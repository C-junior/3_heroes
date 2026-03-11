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
var taunt_target: Node2D = null

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
func apply_wave_scaling(hp_mult: float, dmg_mult: float, elite_mod: String = ""):
	hp_multiplier = hp_mult
	dmg_multiplier = dmg_mult
	if elite_mod != "":
		make_elite(elite_mod)

func make_elite(mod: String):
	scale *= 1.4 # visually bigger
	
	var mod_hp_mult = 1.0
	
	match mod:
		"Giant":
			scale *= 1.3
			mod_hp_mult = 2.0
			move_speed = int(move_speed * 0.7)
			sprite.modulate = Color(1.2, 0.8, 0.8)
		"Swift":
			move_speed = int(move_speed * 1.8)
			attack_cooldown *= 0.6
			sprite.modulate = Color(0.8, 1.2, 0.8)
		"Armored":
			defense += 15
			sprite.modulate = Color(0.6, 0.6, 0.6)
		"Frenzied":
			attack_damage = int(attack_damage * 1.5)
			attack_cooldown *= 0.5
			sprite.modulate = Color(1.5, 0.5, 0.5)
			
	max_health = int(max_health * mod_hp_mult)
	current_health = max_health
	health_progress_bar.max_value = max_health
	health_progress_bar.value = current_health
	original_speed = move_speed
	
	var title = Label.new()
	title.text = "Elite " + mod
	title.add_theme_color_override("font_color", Color(1, 0.8, 0))
	title.add_theme_font_size_override("font_size", 12)
	title.position = Vector2(-25, -50)
	title.z_index = 30
	add_child(title)
	
	xp_reward *= 3
	min_gold_reward *= 3
	max_gold_reward *= 3

func _process(delta: float):
	if taunt_target and is_instance_valid(taunt_target):
		target = taunt_target
	else:
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

func force_attack(forced_target: Node2D, duration: float) -> void:
	taunt_target = forced_target
	taunt_timer.wait_time = duration
	taunt_timer.start()

func _on_taunt_end() -> void:
	taunt_target = null

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
	
	VFX.spawn_death_particles(get_tree().current_scene, global_position, Color(0.2, 0.8, 0.2)) # Greenish blood for goblins
	queue_free()
