# spear_throw.gd
extends Skill

@export var damage_percentage: float = 4.0  # 400% attack damage
@export var skill_range: int = 500
@export var spear_projectile_scene: PackedScene = preload("res://Skills/Valkyrie/spear_projectile.tscn")

var cooldown_timer: Timer = null

func init(character: BaseCharacter) -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	character.add_child(cooldown_timer)
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_ready"))

func apply_effect(character: BaseCharacter) -> void:
	if not cooldown_timer.is_stopped():
		return

	_trigger_spear_throw(character)
	cooldown_timer.start()

# Find the farthest enemy and launch the spear projectile
func _trigger_spear_throw(character: BaseCharacter) -> void:
	var enemies = character.get_tree().get_nodes_in_group("Enemies")
	var farthest_enemy: Node2D = null
	var max_distance: float = 0.0

	# Find the farthest enemy
	for enemy in enemies:
		var distance = character.global_position.distance_to(enemy.global_position)
		if distance > max_distance and distance <= skill_range:
			max_distance = distance
			farthest_enemy = enemy

	# Launch spear projectile at the farthest enemy
	if farthest_enemy:
		var spear = spear_projectile_scene.instantiate() as Area2D
		spear.global_position = character.global_position  # Start at the character's position
		spear.setup(farthest_enemy, character.attack_damage * damage_percentage)  # Set target and damage
		character.get_parent().add_child(spear)
		print("Spear Throw launched towards:", farthest_enemy.name)

func _on_cooldown_ready():
	print("Spear Throw is ready again!")
