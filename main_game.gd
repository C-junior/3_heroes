# main_game.gd
extends Node2D

@onready var wave_manager = preload("res://wave_manager.gd").new()  # Load wave manager as a new instance
@onready var player_characters = $PlayerCharacters
@onready var enemies = $Enemies
@onready var wave_label = $WaveLabel
@onready var wave_manager_timer: Timer = $WaveManager  # Timer managing wave intervals

signal wave_skill_popup  # Signal for skill selection UI
signal game_over(stats: Dictionary)
signal victory(stats: Dictionary)
signal wave_event_triggered(event)
signal show_shop(shop_items: Array, dead_heroes: Array)

var current_wave = 0  # Start at 0 so first wave is 1
var max_waves = 10
var wave_in_progress = false
var game_ended = false
var waiting_for_skill_selection = false

# Stats tracking
var total_kills: int = 0
var total_gold_earned: int = 0
var starting_gold: int = 0

# Systems
var shop_system: ShopSystem = null
var wave_events: WaveEvents = null
var dead_heroes: Array = []  # Track fallen heroes for resurrection

# Camera shake
var shake_intensity: float = 0.0
var shake_decay: float = 5.0
var original_camera_offset: Vector2 = Vector2.ZERO

# Spawn configuration
@export var spawn_area_min: Vector2 = Vector2(500, 50)
@export var spawn_area_max: Vector2 = Vector2(750, 350)

func _ready():
	randomize()
	starting_gold = global.currency
	
	# Initialize shop system
	shop_system = ShopSystem.new()
	add_child(shop_system)
	
	# Initialize wave events
	wave_events = WaveEvents.new()
	add_child(wave_events)
	
	# Place characters in a fixed position
	var characters = player_characters.get_children()
	for i in range(characters.size()):
		characters[i].position = Vector2(100, 100 + i * 100)
		# Connect death signals
		if characters[i].has_signal("hero_died"):
			characters[i].connect("hero_died", Callable(self, "_on_hero_died"))
	
	#wave manager
	add_child(wave_manager)  # Add wave_manager to the scene tree
	wave_manager_timer.connect("timeout", Callable(self, "_on_wave_timer_timeout"))
	
	# Show skill selection at start of game before wave 1
	_show_initial_skill_selection()

func _show_initial_skill_selection():
	waiting_for_skill_selection = true
	wave_label.text = "Prepare Wave 1"
	# Small delay then show skill popup
	await get_tree().create_timer(0.5).timeout
	emit_signal("wave_skill_popup")

func on_skills_confirmed():
	# Called by UI when skills are confirmed
	waiting_for_skill_selection = false
	if current_wave == 0:
		# Start the first wave
		current_wave = 1
		wave_manager_timer.start(1.0)
	else:
		# Continue to next wave
		wave_manager_timer.start(1.5)

func _on_wave_timer_timeout():
	if wave_in_progress or game_ended or waiting_for_skill_selection:
		return

	start_wave()

func start_wave():
	print("Starting wave ", current_wave)
	wave_in_progress = true
	wave_label.text = "Wave %d" % current_wave
	
	# Roll wave event
	var event = wave_events.roll_event(current_wave)
	if event:
		emit_signal("wave_event_triggered", event)
	
	spawn_wave_enemies(current_wave)
	
	# Apply event effects after enemies are spawned
	if event:
		wave_events.apply_event_to_enemies(enemies, player_characters)

func spawn_wave_enemies(wave: int):
	var wave_setup = wave_manager.get_wave_enemies(wave)
	var wave_multiplier = wave_manager.get_wave_multiplier(wave)
	
	# Add ambush extras if event is active
	var ambush_extras = wave_events.get_ambush_extras()
	if ambush_extras.size() > 0:
		wave_setup = wave_setup + ambush_extras

	for enemy_info in wave_setup:
		var enemy_scene_path = enemy_info["scene_path"]
		var enemy_scene = load(enemy_scene_path)
		for i in range(enemy_info["count"]):
			var enemy = enemy_scene.instantiate() as Node2D
			enemies.add_child(enemy)
			# Improved spawn positioning with some spread
			enemy.position = Vector2(
				randf_range(spawn_area_min.x, spawn_area_max.x),
				randf_range(spawn_area_min.y, spawn_area_max.y)
			)
			if enemy.has_method("apply_wave_scaling"):
				enemy.apply_wave_scaling(wave_multiplier)

func check_wave_completion():
	if enemies.get_child_count() == 0 and wave_in_progress:
		wave_in_progress = false
		print("Wave ", current_wave, " cleared!")

		if current_wave >= max_waves:
			_on_victory()
		else:
			# Show skill selection + shop after EVERY wave
			waiting_for_skill_selection = true
			current_wave += 1
			_recover_party_between_waves()
			wave_label.text = "Draft for Wave %d" % current_wave
			
			# Generate shop
			shop_system.generate_shop(current_wave, dead_heroes.size() > 0)
			emit_signal("show_shop", shop_system.current_inventory, dead_heroes)
			
			emit_signal("wave_skill_popup")

func _on_hero_died(character: BaseCharacter):
	if not dead_heroes.has(character):
		dead_heroes.append(character)
	trigger_screen_shake(8.0)
	print("Hero died: ", character.name, " | Dead heroes: ", dead_heroes.size())

func check_player_death():
	# Count alive heroes
	var alive_count = 0
	for hero in player_characters.get_children():
		if hero is BaseCharacter and not hero.is_dead:
			alive_count += 1
	
	if alive_count == 0 and not game_ended:
		_on_game_over()

func _get_run_stats() -> Dictionary:
	return {
		"wave_reached": current_wave,
		"total_kills": total_kills,
		"total_gold_earned": global.currency - starting_gold + global.currency,
		"heroes_fallen": dead_heroes.size(),
	}

func _on_game_over():
	game_ended = true
	wave_manager_timer.stop()
	wave_label.text = "GAME OVER"
	print("GAME OVER - All heroes have fallen!")
	emit_signal("game_over", _get_run_stats())

func _on_victory():
	game_ended = true
	wave_manager_timer.stop()
	wave_label.text = "VICTORY!"
	print("VICTORY - All waves completed!")
	trigger_screen_shake(10.0)
	emit_signal("victory", _get_run_stats())

func _process(delta: float):
	if game_ended or waiting_for_skill_selection:
		# Still process camera shake
		_process_shake(delta)
		return
	
	# Check if the wave is completed in each frame
	check_wave_completion()
	check_player_death()
	
	# Track kills
	_track_kills()
	
	# Camera shake
	_process_shake(delta)

var _last_enemy_count: int = 0

func _track_kills():
	var current_count = enemies.get_child_count()
	if current_count < _last_enemy_count and wave_in_progress:
		var killed = _last_enemy_count - current_count
		total_kills += killed
	_last_enemy_count = current_count

func _recover_party_between_waves():
	for character in player_characters.get_children():
		if character is BaseCharacter and not character.is_dead:
			character.recover_between_waves(0.3)  # 30% heal between waves

func get_skill_tier_for_wave(wave: int) -> int:
	return wave_manager.get_skill_tier_for_wave(wave)

# Camera shake
func trigger_screen_shake(intensity: float):
	shake_intensity = intensity

func _process_shake(delta: float):
	if shake_intensity > 0:
		var offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		position = original_camera_offset + offset
		shake_intensity = max(0, shake_intensity - shake_decay * delta)
	else:
		position = original_camera_offset

# Restart the game
func restart_game():
	global.currency = 100
	get_tree().reload_current_scene()

# Revive a dead hero via shop
func revive_hero(hero: BaseCharacter):
	if dead_heroes.has(hero):
		dead_heroes.erase(hero)
		hero.revive(0.5)
		print("Revived hero: ", hero.name)
