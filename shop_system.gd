# shop_system.gd
extends Node
class_name ShopSystem

# Shop item definition
class ShopItem:
	var item_name: String
	var description: String
	var cost: int
	var item_type: String  # "stat_potion", "full_heal", "revive"
	var stat_key: String  # "attack", "defense", "health", "speed"
	var stat_value: float
	var icon_color: Color
	
	func _init(p_name: String, p_desc: String, p_cost: int, p_type: String, p_stat_key: String = "", p_stat_value: float = 0, p_color: Color = Color.WHITE):
		item_name = p_name
		description = p_desc
		cost = p_cost
		item_type = p_type
		stat_key = p_stat_key
		stat_value = p_stat_value
		icon_color = p_color

# All possible shop items
var item_pool: Array = []
# Current wave's shop inventory (4 random items)
var current_inventory: Array = []
# Reroll cost tracking per hero (escalating)
var reroll_costs: Dictionary = {}
var base_reroll_cost: int = 20

signal purchase_made(item: ShopItem, character: BaseCharacter)
signal reroll_used(character_type: String)

func _ready():
	_build_item_pool()

func _build_item_pool():
	item_pool = [
		ShopItem.new("ATK Potion", "+15 Attack Damage", 40, "stat_potion", "attack", 15, Color(1, 0.3, 0.3)),
		ShopItem.new("HP Potion", "+30 Max Health", 30, "stat_potion", "health", 30, Color(0.3, 1, 0.3)),
		ShopItem.new("DEF Potion", "+5 Defense", 25, "stat_potion", "defense", 5, Color(0.3, 0.5, 1)),
		ShopItem.new("Speed Elixir", "+10 Move Speed", 50, "stat_potion", "speed", 10, Color(1, 1, 0.3)),
		ShopItem.new("Full Heal", "Fully heal one hero", 50, "full_heal", "", 0, Color(0, 1, 0.5)),
		ShopItem.new("ATK Potion+", "+25 Attack Damage", 70, "stat_potion", "attack", 25, Color(1, 0.1, 0.1)),
		ShopItem.new("HP Potion+", "+60 Max Health", 55, "stat_potion", "health", 60, Color(0.1, 1, 0.1)),
		ShopItem.new("DEF Potion+", "+10 Defense", 45, "stat_potion", "defense", 10, Color(0.1, 0.3, 1)),
	]

# Generate a random shop for the current wave
func generate_shop(wave: int, has_dead_heroes: bool = false):
	current_inventory.clear()
	
	# Shuffle and pick 4 items
	var pool = item_pool.duplicate()
	pool.shuffle()
	var count = min(4, pool.size())
	for i in range(count):
		current_inventory.append(pool[i])
	
	# Add revive scroll if a hero has died
	if has_dead_heroes:
		var revive = ShopItem.new("Revive Scroll", "Revive a fallen hero at 50% HP", 100, "revive", "", 0.5, Color(1, 0.85, 0))
		current_inventory.append(revive)
	
	# Reset reroll costs for new wave
	reroll_costs.clear()

# Apply a shop item to a character
func buy_item(item: ShopItem, character: BaseCharacter) -> bool:
	if global.currency < item.cost:
		print("Not enough gold! Need ", item.cost, " but have ", global.currency)
		return false
	
	global.currency -= item.cost
	
	match item.item_type:
		"stat_potion":
			_apply_stat_potion(item, character)
		"full_heal":
			character.current_health = character.max_health
			character.update_health_label()
			print(character.name, " fully healed!")
		"revive":
			character.revive(item.stat_value)
			print(character.name, " has been revived!")
	
	emit_signal("purchase_made", item, character)
	return true

func _apply_stat_potion(item: ShopItem, character: BaseCharacter):
	match item.stat_key:
		"attack":
			character.base_attack_damage += int(item.stat_value)
		"health":
			character.base_max_health += int(item.stat_value)
		"defense":
			character.base_defense += int(item.stat_value)
		"speed":
			character.base_move_speed += int(item.stat_value)
	
	character.update_stats()
	print(character.name, " used ", item.item_name, ": +", item.stat_value, " ", item.stat_key)

# Get reroll cost for a hero (escalates each use)
func get_reroll_cost(hero_name: String) -> int:
	if hero_name not in reroll_costs:
		reroll_costs[hero_name] = 0
	var times_rerolled = reroll_costs[hero_name]
	# 20 -> 30 -> 45 -> 65 -> 90...
	return base_reroll_cost + (times_rerolled * 15)

# Spend gold to reroll, returns true if successful
func do_reroll(hero_name: String) -> bool:
	var cost = get_reroll_cost(hero_name)
	if global.currency < cost:
		print("Not enough gold to reroll! Need ", cost)
		return false
	
	global.currency -= cost
	if hero_name not in reroll_costs:
		reroll_costs[hero_name] = 0
	reroll_costs[hero_name] += 1
	
	emit_signal("reroll_used", hero_name)
	print("Rerolled skills for ", hero_name, " (cost: ", cost, "g)")
	return true
