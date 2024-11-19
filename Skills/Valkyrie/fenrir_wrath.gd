extends Skill

@export var proc_chance: float = 0.25  # 25% chance to proc
@export var bonus_damage_percentage: float = 1.2  # 120% attack damage

func init(character: BaseCharacter) -> void:
	print(character.name, "has learned Fenrir’s Wrath. Each attack has a", proc_chance * 100, "% chance to deal", bonus_damage_percentage * 100, "% bonus damage.")

# Passively applies chance-based bonus damage
func apply_effect(character: BaseCharacter) -> void:
	character.add_method_override("attack", Callable(self, "_apply_fenrirs_wrath"))

func _apply_fenrirs_wrath(character: BaseCharacter, target: Node2D) -> void:
	if randf() <= proc_chance:  # If proc_chance succeeds
		var bonus_damage = character.attack_damage * bonus_damage_percentage
		if target.has_method("take_damage"):
			target.take_damage(bonus_damage)
			print("Fenrir’s Wrath proc! Dealt", bonus_damage, "bonus damage to", target.name)
