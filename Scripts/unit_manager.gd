# unit_manager.gd
# Manages spawning and tracking of player units
extends Node
class_name UnitManager

signal unit_recruited(unit_node)
signal unit_died(unit_node)
signal all_units_dead

var units: Array = []

# Unit type definitions
var unit_types = {
	"Knight": {
		"scene_path": "res://Scenes/knight.tscn",
		"token_cost": 1,
		"description": "Tanky melee fighter. High HP and defense.",
		"type_id": 0  # FIGHTER
	},
	"Cleric": {
		"scene_path": "res://Scenes/cleric.tscn",
		"token_cost": 1,
		"description": "Healer. Restores ally HP.",
		"type_id": 1  # HEALER
	},
	"Wizard": {
		"scene_path": "res://Scenes/wizard.tscn",
		"token_cost": 2,
		"description": "Ranged mage. AoE damage dealer.",
		"type_id": 3  # MAGE
	},
	"Valkyrie": {
		"scene_path": "res://Scenes/valkyrie.tscn",
		"token_cost": 2,
		"description": "Balanced hybrid. Burst damage.",
		"type_id": 2  # VALKYRIE
	}
}

# Formation positions relative to base (offsets from base position)
var formation_offsets = [
	Vector2(120, 0),     # Front center
	Vector2(100, -60),   # Front top
	Vector2(100, 60),    # Front bottom
	Vector2(80, -120),   # Back top
	Vector2(80, 120),    # Back bottom
	Vector2(160, -30),   # Far front top
	Vector2(160, 30),    # Far front bottom
	Vector2(140, 0),     # Far front center
]

var base_position: Vector2 = Vector2(200, 360)

func spawn_starting_unit(parent: Node2D):
	var knight_scene = load(unit_types["Knight"]["scene_path"])
	var knight = knight_scene.instantiate()
	parent.add_child(knight)
	knight.position = base_position + formation_offsets[0]
	units.append(knight)
	knight.tree_exiting.connect(_on_unit_removed.bind(knight))
	GameManager.units_alive = units.size()
	emit_signal("unit_recruited", knight)

func recruit_unit(unit_name: String, parent: Node2D) -> bool:
	if not unit_types.has(unit_name):
		return false
	
	var type_data = unit_types[unit_name]
	
	# Check max units
	if units.size() >= GameManager.get_max_units():
		print("Max units reached!")
		return false
	
	# Check tokens
	if not GameManager.spend_token(type_data["token_cost"]):
		print("Not enough tokens!")
		return false
	
	# Spawn unit
	var scene = load(type_data["scene_path"])
	var unit = scene.instantiate()
	parent.add_child(unit)
	
	# Position in formation
	var idx = units.size()
	if idx < formation_offsets.size():
		unit.position = base_position + formation_offsets[idx]
	else:
		unit.position = base_position + Vector2(randf_range(80, 160), randf_range(-120, 120))
	
	units.append(unit)
	unit.tree_exiting.connect(_on_unit_removed.bind(unit))
	GameManager.units_alive = units.size()
	emit_signal("unit_recruited", unit)
	return true

func _on_unit_removed(unit: Node):
	if unit in units:
		units.erase(unit)
		GameManager.units_alive = units.size()
		emit_signal("unit_died", unit)
		if units.size() == 0:
			emit_signal("all_units_dead")

func heal_all_units(percent: float):
	for unit in units:
		if is_instance_valid(unit) and unit.has_method("receive_heal"):
			var heal_amount = int(unit.max_health * percent)
			unit.receive_heal(heal_amount)

func revive_all_units():
	# Between waves: restore dead units to full health
	# (Only heals existing units — dead ones are gone)
	for unit in units:
		if is_instance_valid(unit):
			unit.current_health = unit.max_health
			unit.update_health_label()

func get_unit_count() -> int:
	return units.size()

func get_available_recruits() -> Array:
	var available = []
	for unit_name in unit_types:
		var data = unit_types[unit_name].duplicate()
		data["name"] = unit_name
		data["can_afford"] = GameManager.recruitment_tokens >= data["token_cost"]
		data["has_space"] = units.size() < GameManager.get_max_units()
		available.append(data)
	return available

func clear_all_units():
	for unit in units:
		if is_instance_valid(unit):
			unit.queue_free()
	units.clear()
	GameManager.units_alive = 0
