# fireball.gd
extends Skill

@export var damage_percentage: float = 3.0  # 100% of attack damage
@export var projectile_scene: PackedScene = preload("res://Skills/Wizard/fireball.tscn")  # Fireball scene
@export var speed: float = 400.0  # Speed of the fireball

var cooldown_timer: Timer = null

# Initialize cooldown for fireball
func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

# Apply the fireball effect (projectile)
func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return  # Fireball is on cooldown

	_shoot_fireball(character)
	cooldown_timer.start()  # Start cooldown

# Shoot the fireball towards the target
func _shoot_fireball(character: BaseCharacter) -> void:
	var target = character.find_nearest_target("Enemies")
	if not target:
		return  # No target found

	# Instantiate the fireball projectile
	var fireball = projectile_scene.instantiate() as Area2D
	fireball.position = character.global_position  # Start at the wizard's position

	# Calculate the direction towards the target
	var direction = (target.global_position - character.global_position).normalized()
	fireball.set_direction(direction)
	
	# Set the fireball damage based on the Wizard's attack damage
	fireball.set_damage(character.attack_damage * damage_percentage)

	# Add the fireball to the scene
	character.get_parent().add_child(fireball)

	print("Fireball cast towards", target.name)

# Cooldown reset
func _on_cooldown_ready():
	print("Fireball is ready to be used again!")
