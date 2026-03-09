# wave_manager.gd
extends Node

# Define each wave configuration with enemy scene paths and counts
# Rebalanced: more enemies early for satisfaction, mini-boss at wave 5, harder gauntlet at 9
var wave_enemies = {
	1: [{"scene_path": "res://Enemies/goblin.tscn", "count": 5}],
	2: [{"scene_path": "res://Enemies/goblin.tscn", "count": 5}, {"scene_path": "res://Enemies/goblin_brute.tscn", "count": 1}],
	3: [{"scene_path": "res://Enemies/goblin.tscn", "count": 4}, {"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 2}],
	4: [{"scene_path": "res://Enemies/goblin_brute.tscn", "count": 2}, {"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 2}, {"scene_path": "res://Enemies/goblin.tscn", "count": 2}],
	5: [{"scene_path": "res://Enemies/goblin_brute.tscn", "count": 2}, {"scene_path": "res://Enemies/goblin.tscn", "count": 3}],  # Mini-boss wave - Warchief added below
	6: [{"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 3}, {"scene_path": "res://Enemies/goblin_brute.tscn", "count": 3}],
	7: [{"scene_path": "res://Enemies/goblin_assassin.tscn", "count": 3}, {"scene_path": "res://Enemies/goblin_berserker.tscn", "count": 2}],
	8: [{"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 2}, {"scene_path": "res://Enemies/goblin_assassin.tscn", "count": 3}, {"scene_path": "res://Enemies/goblin_berserker.tscn", "count": 1}],
	9: [{"scene_path": "res://Enemies/goblin_berserker.tscn", "count": 3}, {"scene_path": "res://Enemies/goblin_assassin.tscn", "count": 2}, {"scene_path": "res://Enemies/goblin_shaman.tscn", "count": 2}],
	10: [{"scene_path": "res://Enemies/king_goblin.tscn", "count": 1}]  # Boss wave
}

# Function to retrieve enemy setup for a specific wave
func get_wave_enemies(wave_number: int) -> Array:
	return wave_enemies.get(wave_number, [])

# Smoother exponential scaling curve
func get_wave_multiplier(wave_number: int) -> float:
	var base = 1.0 + (max(wave_number, 1) - 1) * 0.15
	var exponential = pow(max(wave_number, 1), 1.3) * 0.02
	return base + exponential

func get_skill_tier_for_wave(wave_number: int) -> int:
	if wave_number >= 7:
		return 9
	if wave_number >= 4:
		return 6
	return 3
