# healing_mastery.gd
extends Skill

@export var heal_increase: int = 23

func init(character: BaseCharacter) -> void:
	character.heal_amount += heal_increase
	print(character.name, " has increased healing by ", heal_increase, " from Healing Mastery.")
	
