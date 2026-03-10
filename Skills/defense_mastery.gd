# defense_mastery.gd
extends Skill

func _init():
	is_passive = true
	defense_bonus = 20 # Set the bonus for the base system

func apply_effect(character: BaseCharacter) -> void:
	# Deprecated direct application, handled by update_stats now
	pass
