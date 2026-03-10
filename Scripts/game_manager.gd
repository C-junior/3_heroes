# game_manager.gd
# Global autoload for persistent game state across runs
extends Node

signal gold_changed(new_amount)
signal tokens_changed(new_amount)
signal medals_changed(new_amount)
signal wave_changed(new_wave)

# --- Run State (resets each run) ---
var gold: int = 100
var recruitment_tokens: int = 0
var current_wave: int = 0
var units_alive: int = 0
var max_units: int = 4

# --- Prestige State (persists across runs) ---
var prestige_medals: int = 0
var max_wave_reached: int = 0

var prestige_upgrades: Dictionary = {
	"base_health": 0,     # +10% base HP per level
	"starting_gold": 0,   # +50 starting gold per level
	"max_units": 0,       # +1 max unit per level
	"xp_boost": 0         # +5% XP gain per level
}

# --- Constants ---
const DEMO_VICTORY_WAVE: int = 30
const SAVE_PATH: String = "user://save_data.cfg"

func _ready():
	load_prestige_data()

# --- Gold Management ---
func add_gold(amount: int):
	gold += amount
	emit_signal("gold_changed", gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		emit_signal("gold_changed", gold)
		return true
	return false

# --- Token Management ---
func add_tokens(amount: int):
	recruitment_tokens += amount
	emit_signal("tokens_changed", recruitment_tokens)

func spend_token(cost: int) -> bool:
	if recruitment_tokens >= cost:
		recruitment_tokens -= cost
		emit_signal("tokens_changed", recruitment_tokens)
		return true
	return false

# --- Wave Management ---
func advance_wave():
	current_wave += 1
	if current_wave > max_wave_reached:
		max_wave_reached = current_wave
	emit_signal("wave_changed", current_wave)

func get_wave_rewards() -> Dictionary:
	var rewards = {
		"gold": 50 + (current_wave * 15),
		"tokens": 0
	}
	# Token every 3 waves to allow earlier recruitment
	if current_wave % 3 == 0:
		rewards["tokens"] += 1
	# Boss bonus every 10 waves
	if current_wave % 10 == 0:
		rewards["tokens"] += 2
	return rewards

# --- Prestige ---
func get_prestige_bonus(upgrade_name: String) -> float:
	var level = prestige_upgrades.get(upgrade_name, 0)
	match upgrade_name:
		"base_health":
			return level * 0.10  # +10% per level
		"starting_gold":
			return level * 50.0  # +50 per level
		"max_units":
			return level * 1.0   # +1 per level
		"xp_boost":
			return level * 0.05  # +5% per level
	return 0.0

func calculate_medals_earned() -> int:
	return int(max_wave_reached / 10)

func get_max_units() -> int:
	return max_units + int(get_prestige_bonus("max_units"))

func get_starting_gold() -> int:
	return 100 + int(get_prestige_bonus("starting_gold"))

func purchase_prestige_upgrade(upgrade_name: String) -> bool:
	var level = prestige_upgrades.get(upgrade_name, 0)
	var costs = {
		"base_health": 5,
		"starting_gold": 3,
		"max_units": 10,
		"xp_boost": 7
	}
	var cost = (level + 1) * costs.get(upgrade_name, 5)
	if prestige_medals >= cost:
		prestige_medals -= cost
		prestige_upgrades[upgrade_name] = level + 1
		save_prestige_data()
		emit_signal("medals_changed", prestige_medals)
		return true
	return false

# --- Run Reset ---
func reset_run():
	gold = get_starting_gold()
	recruitment_tokens = 0
	current_wave = 0
	units_alive = 0
	max_units = 4 + int(get_prestige_bonus("max_units"))
	emit_signal("gold_changed", gold)
	emit_signal("tokens_changed", recruitment_tokens)

func prestige():
	var medals_earned = calculate_medals_earned()
	prestige_medals += medals_earned
	save_prestige_data()
	emit_signal("medals_changed", prestige_medals)
	reset_run()

# --- Save/Load ---
func save_prestige_data():
	var config = ConfigFile.new()
	config.set_value("prestige", "medals", prestige_medals)
	config.set_value("prestige", "max_wave", max_wave_reached)
	for key in prestige_upgrades:
		config.set_value("upgrades", key, prestige_upgrades[key])
	config.save(SAVE_PATH)

func load_prestige_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return  # No save file yet
	prestige_medals = config.get_value("prestige", "medals", 0)
	max_wave_reached = config.get_value("prestige", "max_wave", 0)
	for key in prestige_upgrades:
		prestige_upgrades[key] = config.get_value("upgrades", key, 0)
	# Apply prestige bonuses
	max_units = 4 + int(get_prestige_bonus("max_units"))
	gold = get_starting_gold()
