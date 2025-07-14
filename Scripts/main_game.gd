# main_game.gd
extends Node2D

signal wave_started(wave_number)
signal open_shop_requested
signal close_shop_requested

@onready var wave_manager = preload("res://wave_manager.gd").new()
@onready var enemies = $Enemies
@onready var wave_manager_timer: Timer = $WaveManager

var current_wave = 1
var max_waves = 10
var wave_in_progress = false

func _ready():
    add_child(wave_manager)
    wave_manager_timer.connect("timeout", Callable(self, "_on_wave_timer_timeout"))
    wave_manager_timer.start(1.0)

func _on_wave_timer_timeout():
    if wave_in_progress:
        return
    start_wave()

func start_wave():
    print("Starting wave ", current_wave)
    wave_in_progress = true
    emit_signal("wave_started", current_wave)
    spawn_wave_enemies(current_wave)

func spawn_wave_enemies(wave: int):
    var wave_setup = wave_manager.get_wave_enemies(wave)
    for enemy_info in wave_setup:
        var enemy_scene = load(enemy_info["scene_path"])
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
            emit_signal("open_shop_requested")

func _process(delta: float):
    check_wave_completion()

func _on_close_shop():
    get_tree().paused = false
    current_wave += 1
    wave_manager_timer.start(2.0)

func _on_button_pressed() -> void:
    Engine.time_scale = 2
