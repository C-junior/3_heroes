# Item.gd
extends Resource
class_name Item

@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var type: String = ""  # "weapon", "armor", "accessory"
@export var price: int = 0

# Stats
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var health_bonus: int = 0
@export var speed_bonus: int = 0
@export var range_bonus: float = 0.0

# Which character types can equip this item
@export var allowed_types: Array = []  # Array of Constants.CharacterType values

func _init():
	allowed_types = []
