# item_database.gd
extends Node
class_name ItemDatabase

var items: Array[Item] = []

var  healer = Constants.CharacterType.HEALER
var  fighter = Constants.CharacterType.FIGHTER
var  Valkyrie = Constants.CharacterType.VALKYRIE
var  mage = Constants.CharacterType.MAGE


func _ready():
	create_items()

func create_items():
	# Create weapons
# Aqua Blade
	var aqua_blade = Item.new()
	aqua_blade.name = "Aqua Blade"
	aqua_blade.type = "weapon"
	aqua_blade.allowed_types = [fighter]
	aqua_blade.price = 120
	aqua_blade.icon = preload("res://Assets/Items/aqua_blade.png")  # Update with actual path
	aqua_blade.attack_cooldown_modifier = 0.9  # Decrease cooldown
	aqua_blade.attack_bonus = 15
	aqua_blade.defense_bonus = 0
	aqua_blade.speed_bonus = 5  # Increase speed
	aqua_blade.health_bonus = 0
	items.append(aqua_blade)

	# Frostbite Saber
	var frostbite_saber = Item.new()
	frostbite_saber.name = "Frostbite Saber"
	frostbite_saber.type = "weapon"
	frostbite_saber.allowed_types = [fighter]
	frostbite_saber.price = 150
	frostbite_saber.icon = preload("res://Assets/Items/frostbite_saber.png")  # Update with actual path
	frostbite_saber.attack_cooldown_modifier = 1.0  # Normal cooldown
	frostbite_saber.attack_bonus = 20
	frostbite_saber.defense_bonus = 3  # Increase defense
	frostbite_saber.speed_bonus = 0
	frostbite_saber.health_bonus = 0
	items.append(frostbite_saber)

	# Flame Tongue
	var flame_tongue = Item.new()
	flame_tongue.name = "Flame Tongue"
	flame_tongue.type = "weapon"
	flame_tongue.allowed_types = [fighter]
	flame_tongue.price = 200
	flame_tongue.icon = preload("res://Assets/Items/flame_tongue.png")  # Update with actual path
	flame_tongue.attack_cooldown_modifier = 1.1  # Increase cooldown slightly
	flame_tongue.attack_bonus = 25
	flame_tongue.defense_bonus = 0
	flame_tongue.speed_bonus = 0
	flame_tongue.health_bonus = 5  # Minor health boost
	items.append(flame_tongue)

	# Shadow Fang
	var shadow_fang = Item.new()
	shadow_fang.name = "Shadow Fang"
	shadow_fang.type = "weapon"
	shadow_fang.allowed_types = [fighter]
	shadow_fang.price = 250
	shadow_fang.icon = preload("res://Assets/Items/shadow_fang.png")  # Update with actual path
	shadow_fang.attack_cooldown_modifier = 0.8  # Decrease cooldown
	shadow_fang.attack_bonus = 30
	shadow_fang.defense_bonus = 0
	shadow_fang.speed_bonus = -5  # Decrease speed
	shadow_fang.health_bonus = 0
	items.append(shadow_fang)

	# Stormbringer
	var lightbringer = Item.new()
	lightbringer.name = "Lightbringer"
	lightbringer.type = "weapon"
	lightbringer.allowed_types = [fighter]
	lightbringer.price = 300
	lightbringer.icon = preload("res://Assets/Items/lightbringer.png")  # Update with actual path
	lightbringer.attack_cooldown_modifier = 1.0  # Normal cooldown
	lightbringer.attack_bonus = 35
	lightbringer.defense_bonus = 5  # Increase defense
	lightbringer.speed_bonus = 0
	lightbringer.health_bonus = 0
	items.append(lightbringer)

	# Venomstrike
	var blueflame = Item.new()
	blueflame.name = "BlueFlame"
	blueflame.type = "weapon"
	blueflame.allowed_types = [fighter]
	blueflame.price = 220
	blueflame.icon = preload("res://Assets/Items/blueflame.png")  # Update with actual path
	blueflame.attack_cooldown_modifier = 1.05  # Slightly increase cooldown
	blueflame.attack_bonus = 28
	blueflame.defense_bonus = 0
	blueflame.speed_bonus = 5  # Increase speed
	blueflame.health_bonus = 0
	items.append(blueflame)

	# Celestial Edge
	var celestial_edge = Item.new()
	celestial_edge.name = "Celestial Edge"
	celestial_edge.type = "weapon"
	celestial_edge.allowed_types = [fighter]
	celestial_edge.price = 500
	celestial_edge.icon = preload("res://Assets/Items/celestial_edge.png")  # Update with actual path
	celestial_edge.attack_cooldown_modifier = 0.95  # Decrease cooldown
	celestial_edge.attack_bonus = 40
	celestial_edge.defense_bonus = 0
	celestial_edge.speed_bonus = 0
	celestial_edge.health_bonus = 10  # Significant health boost
	items.append(celestial_edge)
	# Crystal Shard
	var crystal_shard = Item.new()
	crystal_shard.name = "Crystal Shard"
	crystal_shard.type = "weapon"
	crystal_shard.allowed_types = [fighter]
	crystal_shard.price = 300
	crystal_shard.icon = preload("res://Assets/Items/crystal_shard.png")  # Update with actual path
	crystal_shard.attack_cooldown_modifier = 1.0
	crystal_shard.attack_bonus = 30  # Balanced with price
	crystal_shard.defense_bonus = 0
	crystal_shard.speed_bonus = 0
	crystal_shard.health_bonus = 0	
	items.append(crystal_shard)

	# Infernal Blade
	var infernal_blade = Item.new()
	infernal_blade.name = "Infernal Blade"
	infernal_blade.type = "weapon"
	infernal_blade.allowed_types = [fighter]
	infernal_blade.price = 450
	infernal_blade.icon = preload("res://Assets/Items/infernal_blade.png")  # Update with actual path
	infernal_blade.attack_cooldown_modifier = 1.0
	infernal_blade.attack_bonus = 38  # High damage for price
	infernal_blade.defense_bonus = 0
	infernal_blade.speed_bonus = -5  # Slower
	infernal_blade.health_bonus = 0
	items.append(infernal_blade)

	var mystic_staff = Item.new()
	mystic_staff.name = "Mystic Staff"
	mystic_staff.type = "weapon"
	mystic_staff.icon = preload("res://Assets/Items/staff.png")
	mystic_staff.attack_bonus = 5
	mystic_staff.allowed_types = [healer, mage]  # Healers and Mages can equip staves
	items.append(mystic_staff)
	# Create armor and accessories similarly

	# Emberstrike Spear
	var emberstrike_spear = Item.new()
	emberstrike_spear.name = "Emberstrike Spear"
	emberstrike_spear.type = "weapon"
	emberstrike_spear.allowed_types = [Valkyrie]
	emberstrike_spear.price = 250
	emberstrike_spear.icon = preload("res://Assets/Items/emberstrike_spear.png")  # Update with actual path
	emberstrike_spear.attack_cooldown_modifier = 1.0
	emberstrike_spear.attack_bonus = 30
	emberstrike_spear.defense_bonus = 0
	emberstrike_spear.speed_bonus = 0
	emberstrike_spear.health_bonus = 5  # Minor health boost
	items.append(emberstrike_spear)

	# Frostbite Lance
	var frostbite_lance = Item.new()
	frostbite_lance.name = "Frostbite Lance"
	frostbite_lance.type = "weapon"
	frostbite_lance.allowed_types = [Valkyrie]
	frostbite_lance.price = 275
	frostbite_lance.icon = preload("res://Assets/Items/frostbite_lance.png")  # Update with actual path
	frostbite_lance.attack_cooldown_modifier = 1.0
	frostbite_lance.attack_bonus = 28
	frostbite_lance.defense_bonus = 2  # Increase defense
	frostbite_lance.speed_bonus = 0
	frostbite_lance.health_bonus = 0
	items.append(frostbite_lance)

	# Tidal Harpoon
	var tidal_harpoon = Item.new()
	tidal_harpoon.name = "Tidal Harpoon"
	tidal_harpoon.type = "weapon"
	tidal_harpoon.allowed_types = [Valkyrie]
	tidal_harpoon.price = 300
	tidal_harpoon.icon = preload("res://Assets/Items/tidal_harpoon.png")  # Update with actual path
	tidal_harpoon.attack_cooldown_modifier = 0.95  # Slightly faster
	tidal_harpoon.attack_bonus = 35
	tidal_harpoon.defense_bonus = 0
	tidal_harpoon.speed_bonus = 5  # Increase speed
	tidal_harpoon.health_bonus = 0
	items.append(tidal_harpoon)

	# Shadowpiercer Spear
	var shadowpiercer_spear = Item.new()
	shadowpiercer_spear.name = "Shadowpiercer Spear"
	shadowpiercer_spear.type = "weapon"
	shadowpiercer_spear.allowed_types = [Valkyrie]
	shadowpiercer_spear.price = 350
	shadowpiercer_spear.icon = preload("res://Assets/Items/shadowpiercer_spear.png")  # Update with actual path
	shadowpiercer_spear.attack_cooldown_modifier = 0.8  # Faster cooldown
	shadowpiercer_spear.attack_bonus = 40
	shadowpiercer_spear.defense_bonus = 0
	shadowpiercer_spear.speed_bonus = -5  # Decrease speed
	shadowpiercer_spear.health_bonus = 0
	items.append(shadowpiercer_spear)

	# Celestial Spear
	var celestial_spear = Item.new()
	celestial_spear.name = "Celestial Spear"
	celestial_spear.type = "weapon"
	celestial_spear.allowed_types = [Valkyrie]
	celestial_spear.price = 400
	celestial_spear.icon = preload("res://Assets/Items/celestial_spear.png")  # Update with actual path
	celestial_spear.attack_cooldown_modifier = 1.0
	celestial_spear.attack_bonus = 38
	celestial_spear.defense_bonus = 3  # Increase defense
	celestial_spear.speed_bonus = 0
	celestial_spear.health_bonus = 0
	items.append(celestial_spear)

	# Ethereal Javelin
	var ethereal_javelin = Item.new()
	ethereal_javelin.name = "Ethereal Javelin"
	ethereal_javelin.type = "weapon"
	ethereal_javelin.allowed_types = [Valkyrie]
	ethereal_javelin.price = 450
	ethereal_javelin.icon = preload("res://Assets/Items/ethereal_javelin.png")  # Update with actual path
	ethereal_javelin.attack_cooldown_modifier = 0.9  # Faster cooldown
	ethereal_javelin.attack_bonus = 42
	ethereal_javelin.defense_bonus = 0
	ethereal_javelin.speed_bonus = 5  # Increase speed
	ethereal_javelin.health_bonus = 10  # Significant health boost
	items.append(ethereal_javelin)
	
	# Armor
	var gold_plate = Item.new()
	gold_plate.name = "Gold Plate"
	gold_plate.type = "armor"
	gold_plate.allowed_types = [fighter]
	gold_plate.price = 100
	gold_plate.icon = preload("res://Assets/Items/shield.png")
	gold_plate.range_bonus = 0
	gold_plate.attack_bonus = 0
	gold_plate.defense_bonus = 30
	gold_plate.speed_bonus = -10
	gold_plate.health_bonus = 80
	items.append(gold_plate)

	var full_armor = Item.new()
	full_armor.name = "Full Plate Armor"
	full_armor.type = "armor"
	full_armor.allowed_types = [healer, mage, fighter,Valkyrie]
	full_armor.price = 250
	full_armor.icon = preload("res://Assets/Items/plate-icon.png")
	full_armor.range_bonus = 0
	full_armor.attack_bonus = 0
	full_armor.defense_bonus = 50
	full_armor.speed_bonus = -15
	full_armor.health_bonus = 100
	items.append(full_armor)


	var amulet = Item.new()
	amulet.name = "ring of Strength"
	amulet.type = "accessory"
	
	amulet.price = 220
	amulet.icon = preload("res://Assets/Items/ring-icon.png")
	amulet.range_bonus = 0
	amulet.attack_bonus = 5
	amulet.defense_bonus = 0
	amulet.speed_bonus = 0
	amulet.allowed_types = [healer, mage, fighter,Valkyrie]
	amulet.health_bonus = 15
	items.append(amulet)


# Function to get all available items
func get_all_items() -> Array[Item]:
	
	return items
