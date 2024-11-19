extends Skill

@export var reflect_percentage: float = 0.2  # Reflect 20% of incoming damage
var original_take_damage: Callable = Callable()  # Initialize as an empty callable

# Initialize the passive effect for Divine Reprisal
func init(character: BaseCharacter) -> void:
	# Check if the character has the 'take_damage' method
	if character.has_method("take_damage"):
		var reflected_damage = damage * reflect_percentage
	# Call the original take_damage method to apply normal damage
		original_take_damage.call(damage)
	
	# Reflect damage back to the attacker
		if character.target and character.target.has_method("take_damage"):
			character.target.take_damage(reflected_damage)
			print("Reflected", reflected_damage, "damage to", character.target.name)
		
			print(character.name, "has learned Divine Reprisal. Reflecting", reflect_percentage * 100, "% of damage.")
	else:
		print("Error: Character does not have 'take_damage' method.")

# Override take_damage to reflect damage
#func _reflect_damage(character: BaseCharacter, damage: int) -> void:
	#var reflected_damage = damage * reflect_percentage
	## Call the original take_damage method to apply normal damage
	#original_take_damage.call(damage)
	#
	## Reflect damage back to the attacker
	#if character.target and character.target.has_method("take_damage"):
		#character.target.take_damage(reflected_damage)
		#print("Reflected", reflected_damage, "damage to", character.target.name)
