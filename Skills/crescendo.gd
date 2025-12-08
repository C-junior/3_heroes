# crescendo.gd
extends Skill

func _init():
	is_passive = true
	health_bonus = 50 # Set the bonus for the base system

func apply_effect(character: BaseCharacter) -> void:
	# We can arguably keep the full heal effect on learn if desired, 
	# but the stat boost is handled by update_stats.
	character.current_health = character.max_health 
	print("Crescendo applied: +", health_bonus, " max health")
