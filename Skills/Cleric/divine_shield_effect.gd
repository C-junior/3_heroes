# divine_shield_effect.gd
extends Node2D

@export var duration: float = 3.0  # Shield duration
@onready var animation_player = $AnimationPlayer  # Reference to AnimationPlayer

func _ready():
	# Start a timer to remove the shield after its duration
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	add_child(timer)
	timer.connect("timeout", Callable(self, "queue_free"))

	# Play the shield activation animation
	if animation_player:
		animation_player.play("activate")  # Ensure you have an "activate" animation
