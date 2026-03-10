# weapon_mastery.gd
extends Skill

@export var is_passive_override: bool = true # Force true for this skill type

func _init():
	is_passive = true
	attack_bonus = 10 # Set the bonus for the base system

func apply_effect(character: BaseCharacter) -> void:
	# Deprecated direct application, handled by update_stats now
	pass
