# wave_manager.gd
extends Node

# Define each wave configuration with enemy scene paths and counts
var wave_enemies = {
	1: [{"scene_path": "res://Enemies/goblin.tscn", "count": 3}],
	2: [{"scene_path": "res://Enemies/goblin.tscn", "count": 5}, {"scene_path": "res://Enemies/goblin_brute.tscn", "count": 1}],
	3: [{"scene_path": "res://Enemies/goblin.tscn", "count": 4}, {"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 2}],
	4: [{"scene_path": "res://Enemies/goblin_brute.tscn", "count": 2}, {"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 2}],
	5: [{"scene_path": "res://Enemies/goblin_berserker.tscn", "count": 3}, {"scene_path": "res://Enemies/goblin.tscn", "count": 4}],
	6: [{"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 3}, {"scene_path": "res://Enemies/goblin_brute.tscn", "count": 3}],
	7: [{"scene_path": "res://Enemies/goblin_assassin.tscn", "count": 3}, {"scene_path": "res://Enemies/goblin.tscn", "count": 2}],
	8: [{"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 2}, {"scene_path": "res://Enemies/goblin_assassin.tscn", "count": 3}],
	9: [{"scene_path": "res://Enemies/goblin_berserker.tscn", "count": 4}],
	10: [{"scene_path": "res://Enemies/king_goblin.tscn", "count": 1}]  # Boss wave
}

# Function to retrieve enemy setup for a specific wave
func get_wave_enemies(wave_number: int) -> Array:
	return wave_enemies.get(wave_number, [])
