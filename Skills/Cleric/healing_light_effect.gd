# healing_light_effect.gd
extends Node2D

@export var lifetime: float = 1.0  # Duration for the healing effect to stay on screen

@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Optional, if you have animations

func _ready():
	# Start a timer to remove the effect after its lifetime
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime
	add_child(timer)
	timer.timeout.connect(self.queue_free)

	# Play animation if present
	if animation_player:
		animation_player.play("healing")
