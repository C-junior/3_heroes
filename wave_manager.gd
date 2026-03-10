# wave_manager.gd
# Procedural wave generation with infinite scaling
extends Node

# Enemy scene paths
const ENEMY_SCENES = {
	"goblin": "res://Enemies/goblin.tscn",
	"goblin_brute": "res://Enemies/goblin_brute.tscn",
	"goblin_shaman": "res://Enemies/goblin_shaman.tscn",
	"goblin_berserker": "res://Enemies/goblin_berserker.tscn",
	"goblin_assassin": "res://Enemies/goblin_assassin.tscn",
	"king_goblin": "res://Enemies/king_goblin.tscn"
}

# When each enemy type unlocks
const ENEMY_UNLOCK_WAVE = {
	"goblin": 1,
	"goblin_brute": 3,
	"goblin_shaman": 5,
	"goblin_berserker": 8,
	"goblin_assassin": 12,
	"king_goblin": 10  # Boss only
}

# Phase scaling configuration
const PHASE_CONFIG = {
	"early": {    # Waves 1-10
		"hp_scale": 1.15,
		"dmg_scale": 1.12,
		"count_base": 3,
		"count_growth": 0.5
	},
	"mid": {      # Waves 11-20
		"hp_scale": 1.25,
		"dmg_scale": 1.20,
		"count_base": 6,
		"count_growth": 0.7
	},
	"late": {     # Waves 21-30
		"hp_scale": 1.40,
		"dmg_scale": 1.35,
		"count_base": 10,
		"count_growth": 0.8
	},
	"endless": {  # Waves 31+
		"hp_scale": 1.60,
		"dmg_scale": 1.50,
		"count_base": 15,
		"count_growth": 1.0
	}
}

func get_wave_phase(wave: int) -> String:
	if wave <= 10:
		return "early"
	elif wave <= 20:
		return "mid"
	elif wave <= 30:
		return "late"
	else:
		return "endless"

func get_wave_enemies(wave_number: int) -> Array:
	var phase = get_wave_phase(wave_number)
	var config = PHASE_CONFIG[phase]
	var enemies = []
	
	# Boss wave every 10 waves
	if wave_number % 10 == 0:
		enemies.append({
			"scene_path": ENEMY_SCENES["king_goblin"],
			"count": 1,
			"hp_multiplier": _get_hp_multiplier(wave_number, config),
			"dmg_multiplier": _get_dmg_multiplier(wave_number, config)
		})
		# Add some regular enemies alongside boss
		if wave_number > 10:
			var regular = _get_regular_enemies(wave_number, config)
			for r in regular:
				r["count"] = max(int(r["count"] * 0.5), 1)
				enemies.append(r)
		return enemies
	
	# Regular wave
	return _get_regular_enemies(wave_number, config)

func _get_regular_enemies(wave: int, config: Dictionary) -> Array:
	var enemies = []
	var available_types = _get_available_enemy_types(wave)
	
	# Total enemy count for this wave
	var total_count = int(config["count_base"] + (wave * config["count_growth"]))
	total_count = min(total_count, 25)  # Cap at 25 enemies per wave
	
	# Distribute among available types
	var hp_mult = _get_hp_multiplier(wave, config)
	var dmg_mult = _get_dmg_multiplier(wave, config)
	
	if available_types.size() == 1:
		enemies.append({
			"scene_path": ENEMY_SCENES[available_types[0]],
			"count": total_count,
			"hp_multiplier": hp_mult,
			"dmg_multiplier": dmg_mult
		})
	else:
		# Mix enemy types
		var remaining = total_count
		for i in range(available_types.size()):
			var type_name = available_types[i]
			var count: int
			if i == available_types.size() - 1:
				count = remaining
			else:
				count = max(int(remaining * randf_range(0.2, 0.5)), 1)
				remaining -= count
			
			if count > 0:
				enemies.append({
					"scene_path": ENEMY_SCENES[type_name],
					"count": count,
					"hp_multiplier": hp_mult,
					"dmg_multiplier": dmg_mult
				})
	
	return enemies

func _get_available_enemy_types(wave: int) -> Array:
	var types = []
	for type_name in ENEMY_UNLOCK_WAVE:
		if type_name == "king_goblin":
			continue  # Boss is handled separately
		if wave >= ENEMY_UNLOCK_WAVE[type_name]:
			types.append(type_name)
	return types

func _get_hp_multiplier(wave: int, config: Dictionary) -> float:
	return pow(config["hp_scale"], wave - 1)

func _get_dmg_multiplier(wave: int, config: Dictionary) -> float:
	return pow(config["dmg_scale"], wave - 1)

func get_wave_description(wave: int) -> String:
	if wave % 10 == 0:
		return "⚔️ BOSS WAVE " + str(wave) + " ⚔️"
	else:
		return "Wave " + str(wave)
