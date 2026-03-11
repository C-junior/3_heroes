# base.gd
# The castle/base that the player must defend
extends StaticBody2D
class_name Base

signal base_damaged(current_hp, max_hp)
signal base_destroyed

@export var base_max_health: int = 1000
@export var base_defense: int = 5
@export var regen_per_second: float = 0.0

var current_health: int

func _ready():
	# Apply prestige bonus
	var bonus = GameManager.get_prestige_bonus("base_health")
	base_max_health = int(base_max_health * (1.0 + bonus))
	current_health = base_max_health
	add_to_group("Base")

func _process(delta: float):
	# Passive regen
	if regen_per_second > 0 and current_health < base_max_health:
		current_health = min(current_health + int(regen_per_second * delta), base_max_health)
		emit_signal("base_damaged", current_health, base_max_health)

func take_damage(amount: int):
	var reduced = max(amount - base_defense, 1)
	current_health -= reduced
	emit_signal("base_damaged", current_health, base_max_health)
	
	# Shake the screen when the base takes damage
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("trigger_screen_shake"):
		main_node.trigger_screen_shake(clamp(reduced / 10.0, 3.0, 10.0))
		
	if current_health <= 0:
		current_health = 0
		emit_signal("base_destroyed")

func repair(amount: int):
	current_health = min(current_health + amount, base_max_health)
	emit_signal("base_damaged", current_health, base_max_health)

func get_repair_cost() -> int:
	return int(base_max_health * 0.1)  # 10% of max health as gold cost

func repair_with_gold() -> bool:
	var cost = get_repair_cost()
	if GameManager.spend_gold(cost):
		repair(int(base_max_health * 0.25))  # Heal 25%
		return true
	return false

func get_health_percent() -> float:
	return float(current_health) / float(base_max_health)

func heal_between_waves():
	# Auto-heal 10% between waves
	repair(int(base_max_health * 0.1))
