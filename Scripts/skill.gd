# skill.gd
extends Resource
class_name Skill

@export var name: String = ""
@export var description: String = ""
@export var effect_type: String = ""
@export var effect_value: int = 0
@export var cooldown: float = 0.0
@export var icon: Texture2D

func init(character: BaseCharacter) -> void:
	apply_effect(character)


# This base method is meant to be overridden by specific skill implementations
func apply_effect(character: BaseCharacter) -> void:
	print("Base Skill apply_effect called (should be overridden):", name)
