# weapon_mastery.gd
extends Skill

@export var attack_bonus: int = 10  # +10 attack bonus


func apply_effect(character: BaseCharacter) -> void:
	character.attack_damage += attack_bonus
	print("Weapon Mastery applied: +", attack_bonus, " attack damage")
