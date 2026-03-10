# skill_database.gd
extends Node
class_name SkillDatabase

# Initialize skills for each character type and level
var skills = {}

func _ready():
	# Knight Skills
	skills[Constants.CharacterType.FIGHTER] = {
		3: [_create_shield_bash(), _create_might_aura(), _create_charge()],
		7: [_create_vorpal_slash(), _create_defense_mastery(), _create_weapon_mastery()],
		15: [_create_crescendo(), _create_taunt(), _create_big_shield()]
	}
	
	# Cleric Skills
	skills[Constants.CharacterType.HEALER] = {
		3: [_create_purifying_wave(), _create_healing_light(), _create_divine_shield()],
		7: [_create_holy_hands(), _create_radiant_aura(), _create_mass_heal()],
		15: [_create_defense_mastery(), _create_healing_mastery(), _create_crescendo()]
	}
	
	# Valkyrie Skills
	skills[Constants.CharacterType.VALKYRIE] = {
		3: [_create_spear_throw(), _create_valhallas_call(), _create_thunder_strike()],
		7: [_create_fenrirs_wrath(), _create_ragnarok(), _create_valkyries_zeal()],
		15: [_create_crescendo(), _create_weapon_mastery(), _create_defense_mastery()]
	}
	
	# Wizard Skills
	skills[Constants.CharacterType.MAGE] = {
		3: [_create_fireball(), _create_ice_nova(), _create_black_hole()],
		7: [_create_meteor_strike(), _create_arcane_shield(), _create_haste()],
		15: [_create_chain_lightning(), _create_haste(), _create_weapon_mastery()]
	}

# Sample Skill Creation Functions

# Knight Skills
func _create_vorpal_slash() -> Skill:
	var vorpal_slash = load("res://Skills/vorpal_slash.gd").new()
	vorpal_slash.name = "Vorpal Slash"
	vorpal_slash.description = "Spin and deal 80% attack damage to nearby enemies."
	vorpal_slash.cooldown = 10
	vorpal_slash.icon = null
	return vorpal_slash

func _create_weapon_mastery() -> Skill:
	var weapon_mastery = load("res://Skills/weapon_mastery.gd").new()
	weapon_mastery.name = "Weapon Mastery"
	weapon_mastery.description = "Gain +10 attack damage."
	weapon_mastery.icon = null
	return weapon_mastery

func _create_shield_bash() -> Skill:
	var shield_bash = load("res://Skills/shield_bash.gd").new()
	shield_bash.name = "Shield Bash"
	shield_bash.description = "Stun enemies for 2 seconds."
	shield_bash.cooldown = 8
	shield_bash.icon = null
	return shield_bash
func _create_might_aura() -> Skill:
	var might_aura = load("res://Skills/might_aura.gd").new()
	might_aura.name = "Might Aura"
	might_aura.description = "Reduces attack and defense of all nearby enemies."
	might_aura.cooldown = 15
	might_aura.icon = null
	return might_aura

func _create_charge() -> Skill:
	var charge = load("res://Skills/charge.gd").new()
	charge.name = "Charge"
	charge.description = "Knocks back enemies in a path."
	charge.cooldown = 10
	charge.icon = null
	return charge

func _create_defense_mastery() -> Skill:
	var defense_mastery = load("res://Skills/defense_mastery.gd").new()
	defense_mastery.name = "Defense Mastery"
	defense_mastery.description = "Increase defense by +5."
	defense_mastery.icon = null
	return defense_mastery

func _create_crescendo() -> Skill:
	var crescendo = load("res://Skills/crescendo.gd").new()
	crescendo.name = "Crescendo"
	crescendo.description = "Gain +50 max health."
	crescendo.icon = null
	return crescendo

func _create_taunt() -> Skill:
	var taunt = load("res://Skills/taunt.gd").new()
	taunt.name = "Taunt"
	taunt.description = "Force nearby enemies to attack for 5 seconds."
	taunt.cooldown = 8
	taunt.icon = null
	return taunt

func _create_big_shield() -> Skill:
	var big_shield = load("res://Skills/big_shield.gd").new()
	big_shield.name = "Big Shield"
	big_shield.description = "Blocks 3 attacks within 10 seconds."
	big_shield.cooldown = 10
	big_shield.icon = null
	return big_shield
# Cleric Skills
func _create_holy_hands() -> Skill:
	var holy_hands = load("res://Skills/holy_hands.gd").new()
	holy_hands.name = "Holy Hands"
	holy_hands.description = "Empower an ally's next 3 attacks with extra damage."
	holy_hands.cooldown = 12
	holy_hands.icon = null
	return holy_hands

func _create_healing_light() -> Skill:
	var healing_light = load("res://Skills/healing_light.gd").new()
	healing_light.name = "Healing Light"
	healing_light.description = "Heal an ally for 20% of max health."
	healing_light.cooldown = 10
	healing_light.icon = null
	return healing_light

func _create_purifying_wave() -> Skill:
	var purifying_wave = load("res://Skills/purifying_wave.gd").new()
	purifying_wave.name = "Purifying Wave"
	purifying_wave.description = "Heal all allies and remove debuffs like poison."
	purifying_wave.cooldown = 15
	purifying_wave.icon = null
	return purifying_wave
func _create_radiant_aura() -> Skill:
	var radiant_aura = load("res://Skills/radiant_aura.gd").new()
	radiant_aura.name = "Radiant Aura"
	radiant_aura.description = "Regenerate HP of all allies for 5 seconds."
	radiant_aura.cooldown = 15
	radiant_aura.icon = null
	return radiant_aura

func _create_mass_heal() -> Skill:
	var mass_heal = load("res://Skills/mass_heal.gd").new()
	mass_heal.name = "Mass Heal"
	mass_heal.description = "Heal all allies by 20% of max health."
	mass_heal.cooldown = 30
	mass_heal.icon = null
	return mass_heal

func _create_divine_shield() -> Skill:
	var divine_shield = load("res://Skills/divine_shield.gd").new()
	divine_shield.name = "Divine Shield"
	divine_shield.description = "Make an ally with the lowest HP immune to damage for 3 seconds."
	divine_shield.cooldown = 10
	divine_shield.icon = null
	return divine_shield

func _create_healing_mastery() -> Skill:
	var healing_mastery = load("res://Skills/healing_mastery.gd").new()
	healing_mastery.name = "Healing Mastery"
	healing_mastery.description = "Increase healing base amount by 20."
	healing_mastery.icon = null
	return healing_mastery

# Valkyrie Skills
func _create_spear_throw() -> Skill:
	var spear_throw = load("res://Skills/Valkyrie/spear_throw.gd").new()
	spear_throw.name = "Spear Throw"
	spear_throw.description = "Throws a spear at the farthest enemy."
	spear_throw.cooldown = 3
	spear_throw.icon = null
	return spear_throw

func _create_valhallas_call() -> Skill:
	var valhallas_call = load("res://Skills/Valkyrie/valhallas_call.gd").new()
	valhallas_call.name = "Valhalla's Call"
	valhallas_call.description = "When HP is below 20%, reduce cooldown, increase speed, and grant lifesteal."
	valhallas_call.cooldown = 10
	valhallas_call.icon = null
	return valhallas_call

func _create_thunder_strike() -> Skill:
	var thunder_strike = load("res://Skills/Valkyrie/thunder_strike.gd").new()
	thunder_strike.name = "Thunder Strike"
	thunder_strike.description = "Deal lightning damage to a random enemy."
	thunder_strike.cooldown = 8
	thunder_strike.icon = null
	return thunder_strike

func _create_ragnarok() -> Skill:
	var ragnarok = load("res://Skills/Valkyrie/ragnarok.gd").new()
	ragnarok.name = "Ragnarök"
	ragnarok.description = "Deal massive damage to all enemies."
	ragnarok.cooldown = 20
	ragnarok.icon = null
	return ragnarok

func _create_valkyries_zeal() -> Skill:
	var zeal = load("res://Skills/Valkyrie/valkyries_zeal.gd").new()
	zeal.name = "Valkyrie's Zeal"
	zeal.description = "Increase attack speed by 20% for 5 seconds."
	zeal.cooldown = 15
	zeal.icon = null
	return zeal
func _create_fenrirs_wrath() -> Skill:
	var fenrirs_wrath = load("res://Skills/Valkyrie/fenrir_wrath.gd").new()
	fenrirs_wrath.name = "Fenrir's Wrath"
	fenrirs_wrath.description = "25% chance to deal 120% attack damage."
	fenrirs_wrath.icon = null
	return fenrirs_wrath

# Wizard Skills
func _create_fireball() -> Skill:
	var fireball = load("res://Skills/Wizard/fireball.gd").new()
	fireball.name = "Fireball"
	fireball.description = "Deal 80 damage to the nearest enemy."
	fireball.cooldown = 5
	fireball.icon = null
	return fireball

func _create_ice_nova() -> Skill:
	var ice_nova = load("res://Skills/Wizard/ice_nova.gd").new()
	ice_nova.name = "Ice Nova"
	ice_nova.description = "Deals damage and slows enemies in an area."
	ice_nova.cooldown = 8
	ice_nova.icon = null
	return ice_nova

func _create_meteor_strike() -> Skill:
	var meteor_strike = load("res://Skills/Wizard/meteor_strike.gd").new()
	meteor_strike.name = "Meteor Strike"
	meteor_strike.description = "Calls down a meteor, dealing damage to all enemies in an area."
	meteor_strike.cooldown = 10
	meteor_strike.icon = null
	return meteor_strike

func _create_haste() -> Skill:
	var haste = load("res://Skills/Wizard/haste.gd").new()
	haste.name = "Haste"
	haste.description = "Reduces cooldowns by 20% for 10 seconds."
	haste.cooldown = 15
	haste.icon = null
	return haste

func _create_chain_lightning() -> Skill:
	var chain_lightning = load("res://Skills/Wizard/chain_lightning.gd").new()
	chain_lightning.name = "Chain Lightning"
	chain_lightning.description = "Jumps to up to 3 enemies, dealing reduced damage on each hit."
	chain_lightning.cooldown = 10
	chain_lightning.icon = null
	return chain_lightning

func _create_black_hole() -> Skill:
	var black_hole = load("res://Skills/Wizard/black_hole.gd").new()
	black_hole.name = "Black Hole"
	black_hole.description = "Creates a gravitational field, pulling in enemies and dealing continuous damage."
	black_hole.cooldown = 12
	black_hole.icon = null
	return black_hole
func _create_arcane_shield() -> Skill:
	var arcane_shield = load("res://Skills/Wizard/arcane_shield.gd").new()
	arcane_shield.name = "Arcane Shield"
	arcane_shield.description = "Summons a shield that absorbs damage for a short duration."
	arcane_shield.cooldown = 12
	arcane_shield.icon = null
	return arcane_shield

# Randomly select 3 skills for each wave
func get_skills_for_level(character_type: int, level: int) -> Array:
	if character_type in skills and level in skills[character_type]:
		var available_skills = skills[character_type][level].duplicate() # Duplicate to avoid modifying original
		var chosen_skills = []
		while chosen_skills.size() < 3 and available_skills.size() > 0:
			var index = randi() % available_skills.size()
			chosen_skills.append(available_skills[index])
			available_skills.remove_at(index)
		return chosen_skills
	return []  # No skills available for this level
