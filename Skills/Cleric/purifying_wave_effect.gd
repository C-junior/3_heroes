# purifying_wave_effect.gd
extends Node2D

@export var lifetime: float = 1.5  # Duration of the purifying wave animation

@onready var animation_player = $AnimationPlayer  # Reference to the AnimationPlayer

func _ready():
	# Start a timer to remove the effect after its lifetime
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime
	add_child(timer)
	timer.connect("timeout", Callable(self, "queue_free"))

	# Play the purifying animation if available
	if animation_player:
		animation_player.play("purify")  # Ensure you have a "purify" animation
