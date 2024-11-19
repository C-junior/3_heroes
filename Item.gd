# item.gd
extends Resource
class_name Item

@export var icon: Texture2D
@export var name: String
@export var type: String  # "weapon", "armor", or "accessory"
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var attack_cooldown_modifier: float = 1.0
@export var speed_bonus: int = 0
@export var health_bonus: int = 0
@export var price: int = 100
@export var range_bonus: int = 0

# Add the new allowed_types property
@export var allowed_types: Array

# Example:
# allowed_types = [CharacterType.FIGHTER, CharacterType.RANGED]


#func _init(name: String, type: String, attack_bonus: int = 0, defense_bonus: int = 0, speed_bonus: int = 0, health_bonus: int = 0, price: int = 100):
	#self.icon = icon
	#self.name = name
	#self.type = type
	#self.attack_bonus = attack_bonus
	#self.range = range_bonus
	#self.defense_bonus = defense_bonus
	#self.speed_bonus = speed_bonus
	#self.health_bonus = health_bonus
	#self.price = price
