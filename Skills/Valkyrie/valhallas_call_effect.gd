# valhallas_call_effect.gd
extends Node2D

@export var duration: float = 5.0  # Effect duration
@export var effect_color: Color = Color(1, 0.5, 0)  # Golden glow
@onready var animation_player = $AnimationPlayer
@onready var particles = $GPUParticles2D  # Optional particles

func _ready():
	# Start a timer to remove the effect after the duration
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	add_child(timer)
	timer.connect("timeout", Callable(self, "queue_free"))

	# Play animation if available
	if animation_player:
		animation_player.play("activate")
