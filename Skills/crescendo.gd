# crescendo.gd
extends Skill

@export var health_bonus: int = 50  # +50 max health bonus

func apply_effect(character: BaseCharacter) -> void:
	character.max_health += health_bonus
	character.current_health = character.max_health  # Heal to full
	print("Crescendo applied: +", health_bonus, " max health")
