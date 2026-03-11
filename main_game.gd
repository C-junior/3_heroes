# main_game.gd
# Core game loop with state machine: PREPARATION → WAVE_ACTIVE → GAME_OVER/VICTORY
extends Node2D

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal game_over
signal victory
signal open_shop_requested
signal wave_event_triggered(event_data: Dictionary)

@onready var wave_manager = preload("res://wave_manager.gd").new()
@onready var enemies_node = $Enemies
@onready var player_characters = $PlayerCharacters
@onready var base_node: Base = $Base

var unit_manager: UnitManager = UnitManager.new()

enum GameState {
	PREPARATION,
	WAVE_ACTIVE,
	GAME_OVER,
	VICTORY
}

var game_state: int = GameState.PREPARATION
var wave_check_timer: float = 0.0

# Camera Shake Variables
var camera: Camera2D
var shake_intensity: float = 0.0
var shake_decay: float = 60.0

func _ready():
	add_child(wave_manager)
	add_child(unit_manager)
	
	# Connect base signals
	base_node.connect("base_destroyed", Callable(self, "_on_base_destroyed"))
	
	# Connect unit manager signals
	unit_manager.connect("all_units_dead", Callable(self, "_on_all_units_dead"))
	
	# Initialize run
	GameManager.reset_run()
	
	# Spawn starting unit
	unit_manager.spawn_starting_unit(player_characters)
	
	# Build camera for screen shake
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	add_child(camera)
	camera.make_current()

	# Start in preparation
	game_state = GameState.PREPARATION
	print("Game started! Press Start Wave to begin.")

func start_wave():
	if game_state != GameState.PREPARATION:
		return
	
	GameManager.advance_wave()
	game_state = GameState.WAVE_ACTIVE
	print(wave_manager.get_wave_description(GameManager.current_wave))
	
	wave_manager.generate_wave_event(GameManager.current_wave)
	if wave_manager.current_event.has("type"):
		emit_signal("wave_event_triggered", wave_manager.current_event)
	
	emit_signal("wave_started", GameManager.current_wave)
	spawn_wave_enemies(GameManager.current_wave)

func spawn_wave_enemies(wave: int):
	var wave_setup = wave_manager.get_wave_enemies(wave)
	for enemy_info in wave_setup:
		var enemy_scene = load(enemy_info["scene_path"])
		for i in range(enemy_info["count"]):
			var enemy = enemy_scene.instantiate() as Node2D
			enemies_node.add_child(enemy)
			# Spawn on the right side
			enemy.position = Vector2(randf_range(900, 1100), randf_range(150, 550))
			
			# Apply scaling multipliers
			if enemy.has_method("apply_wave_scaling"):
				var elite_mod = enemy_info.get("elite_modifier", "")
				enemy.apply_wave_scaling(enemy_info["hp_multiplier"], enemy_info["dmg_multiplier"], elite_mod)

func check_wave_completion():
	if enemies_node.get_child_count() == 0 and game_state == GameState.WAVE_ACTIVE:
		_on_wave_completed()

func _on_wave_completed():
	game_state = GameState.PREPARATION
	var wave = GameManager.current_wave
	print("Wave ", wave, " cleared!")
	wave_manager.clear_wave_event()
	
	# Grant rewards
	var rewards = GameManager.get_wave_rewards()
	GameManager.add_gold(rewards["gold"])
	if rewards["tokens"] > 0:
		GameManager.add_tokens(rewards["tokens"])
		print("Earned ", rewards["tokens"], " recruitment token(s)!")
	
	# Auto-heal units and base between waves
	unit_manager.heal_all_units(0.2)  # 20% heal
	base_node.heal_between_waves()    # 10% base heal
	
	emit_signal("wave_completed", wave)
	
	# Check for demo victory
	if wave >= GameManager.DEMO_VICTORY_WAVE:
		game_state = GameState.VICTORY
		emit_signal("victory")
		print("🎉 VICTORY! Demo completed at wave ", wave, "!")
	else:
		# Open shop for preparation
		emit_signal("open_shop_requested")

func _on_base_destroyed():
	if game_state == GameState.GAME_OVER:
		return
	game_state = GameState.GAME_OVER
	print("💀 GAME OVER! Base destroyed at wave ", GameManager.current_wave)
	emit_signal("game_over")

func _on_all_units_dead():
	# All units dead — enemies will now attack the base
	print("⚠️ All defenders have fallen! Base is unprotected!")

func _process(delta: float):
	if shake_intensity > 0:
		shake_intensity = max(0, shake_intensity - shake_decay * delta)
		camera.offset = Vector2(
			randf_range(-1.0, 1.0) * shake_intensity,
			randf_range(-1.0, 1.0) * shake_intensity
		)
	else:
		camera.offset = Vector2.ZERO

	if game_state == GameState.WAVE_ACTIVE:
		# Check wave completion periodically
		wave_check_timer += delta
		if wave_check_timer >= 0.5:
			wave_check_timer = 0.0
			check_wave_completion()

# --- UI Callbacks ---
func _on_start_wave_pressed():
	start_wave()

func _on_close_shop():
	# Shop closed, stay in preparation (player decides when to start wave)
	pass

func set_game_speed(speed: float):
	Engine.time_scale = speed

func trigger_screen_shake(intensity: float):
	shake_intensity = max(shake_intensity, intensity * 5.0)
