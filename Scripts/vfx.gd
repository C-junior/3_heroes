# vfx.gd
extends Node
class_name VFX

# Spawn a burst of particles for hits
static func spawn_hit_particles(parent: Node, pos: Vector2, color: Color = Color.WHITE):
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.amount = 12
	particles.lifetime = 0.4
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 120.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = color
	particles.position = pos
	particles.z_index = 20
	
	parent.add_child(particles)
	particles.emitting = true
	
	_auto_cleanup(particles, 1.0)

# Spawn particles for level up
static func spawn_level_up_particles(parent: Node, pos: Vector2):
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.amount = 30
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(20, 5)
	particles.direction = Vector2(0, -1)
	particles.spread = 20.0
	particles.gravity = Vector2(0, -50)
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 150.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 8.0
	particles.color = Color(1.0, 0.9, 0.2) # Gold/Yellow
	particles.position = pos
	particles.z_index = 25
	
	parent.add_child(particles)
	particles.emitting = true
	
	_auto_cleanup(particles, 1.5)

# Spawn smaller blood splat/death effect
static func spawn_death_particles(parent: Node, pos: Vector2, color: Color = Color(0.8, 0.1, 0.1)):
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.amount = 25
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.spread = 180.0
	particles.gravity = Vector2(0, 150)
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 160.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0
	particles.color = color
	particles.position = pos
	particles.z_index = 10
	
	parent.add_child(particles)
	particles.emitting = true
	
	_auto_cleanup(particles, 1.5)

# Helper for memory cleanup
static func _auto_cleanup(node: Node, wait_time: float):
	var tree = node.get_tree()
	if tree:
		var timer = tree.create_timer(wait_time)
		timer.connect("timeout", Callable(node, "queue_free"))
