# main_game.gd
extends Node2D

@onready var wave_manager = preload("res://wave_manager.gd").new()  # Load wave manager as a new instance
@onready var player_characters = $PlayerCharacters
@onready var enemies = $Enemies
@onready var wave_label = $WaveLabel
@onready var wave_manager_timer: Timer = $WaveManager  # Timer managing wave intervals

var current_wave = 1
var max_waves = 10
var wave_in_progress = false

func _ready():
	# Place characters in a fixed position
	var characters = player_characters.get_children()
	for i in range(characters.size()):
		characters[i].position = Vector2(100, 100 + i * 100)

	#wave manager
	add_child(wave_manager)  # Add wave_manager to the scene tree
	wave_manager_timer.connect("timeout", Callable(self, "_on_wave_timer_timeout"))  # Connect timer to wave start
	wave_manager_timer.start(1.0)  # Start timer with delay for the initial wave

func _on_wave_timer_timeout():
	if wave_in_progress:
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
			enemy.position = Vector2(randf_range(500, 700), randf_range(100, 300))

func check_wave_completion():
	if enemies.get_child_count() == 0 and wave_in_progress:
		wave_in_progress = false
		print("Wave ", current_wave, " cleared!")

		if current_wave >= max_waves:
			print("All waves completed!")
			wave_manager_timer.stop()
		else:
			current_wave += 1
			wave_manager_timer.start(2.0)  # Start the timer to trigger the next wave after a short delay

func _process(delta: float):
	# Check if the wave is completed in each frame
	check_wave_completion()
	
