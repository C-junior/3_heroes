# main_game.gd
extends Node2D

@onready var wave_manager = preload("res://wave_manager.gd").new()  # Load wave manager as a new instance
@onready var player_characters = $PlayerCharacters
@onready var enemies = $Enemies
@onready var wave_label = $WaveLabel
@onready var wave_manager_timer: Timer = $WaveManager  # Timer managing wave intervals

signal wave_skill_popup  # Signal for skill selection UI
signal game_over
signal victory

var current_wave = 0  # Start at 0 so first wave is 1
var max_waves = 10
var wave_in_progress = false
var game_ended = false
var waiting_for_skill_selection = false

# Spawn configuration
@export var spawn_area_min: Vector2 = Vector2(500, 50)
@export var spawn_area_max: Vector2 = Vector2(750, 350)

func _ready():
	# Place characters in a fixed position
	var characters = player_characters.get_children()
	for i in range(characters.size()):
		characters[i].position = Vector2(100, 100 + i * 100)

	#wave manager
	add_child(wave_manager)  # Add wave_manager to the scene tree
	wave_manager_timer.connect("timeout", Callable(self, "_on_wave_timer_timeout"))
	
	# Show skill selection at start of game before wave 1
	_show_initial_skill_selection()

func _show_initial_skill_selection():
	waiting_for_skill_selection = true
	wave_label.text = "Choose Skills!"
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
	wave_label.text = "Wave " + str(current_wave)

	spawn_wave_enemies(current_wave)

func spawn_wave_enemies(wave: int):
	var wave_setup = wave_manager.get_wave_enemies(wave)

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

func check_wave_completion():
	if enemies.get_child_count() == 0 and wave_in_progress:
		wave_in_progress = false
		print("Wave ", current_wave, " cleared!")

		if current_wave >= max_waves:
			_on_victory()
		else:
			# Show skill selection after EVERY wave
			waiting_for_skill_selection = true
			wave_label.text = "Choose Skills!"
			emit_signal("wave_skill_popup")
			current_wave += 1

func check_player_death():
	if player_characters.get_child_count() == 0 and not game_ended:
		_on_game_over()

func _on_game_over():
	game_ended = true
	wave_manager_timer.stop()
	wave_label.text = "GAME OVER"
	print("GAME OVER - All heroes have fallen!")
	emit_signal("game_over")

func _on_victory():
	game_ended = true
	wave_manager_timer.stop()
	wave_label.text = "VICTORY!"
	print("VICTORY - All waves completed!")
	emit_signal("victory")

func _process(delta: float):
	if game_ended or waiting_for_skill_selection:
		return
	
	# Check if the wave is completed in each frame
	check_wave_completion()
	check_player_death()
