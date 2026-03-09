# skill.gd
extends Resource
class_name Skill

@export var name: String = ""
@export var description: String = ""
@export var effect_type: String = ""
@export var effect_value: int = 0
@export var cooldown: float = 0.0
@export var icon: Texture2D

# New properties for generic stat handling
@export var is_passive: bool = false
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var health_bonus: int = 0

func init(character: BaseCharacter) -> void:
	pass


# This base method is meant to be overridden by specific skill implementations
func apply_effect(character: BaseCharacter) -> void:
	print("Base Skill apply_effect called (should be overridden):", name)

# Apply passive effects (stat boosts)
func apply_passive_effect(character: BaseCharacter) -> void:
	if not is_passive:
		return
	
	print("Applying passive effect for skill:", name)
	# Logic for applying stats is handled in character.update_stats() normally,
	# but we can do immediate one-time effects here if needed.
	# For now, we mainly use this to log or trigger side effects.
