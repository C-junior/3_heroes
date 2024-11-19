# defense_mastery.gd
extends Skill

@export var defense_bonus: int = 20  # +5 defense bonus


func apply_effect(character: BaseCharacter) -> void:
	character.defense += defense_bonus
	print("Defense Mastery applied: +", defense_bonus, " defense")
