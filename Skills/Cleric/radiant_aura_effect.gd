# radiant_aura_effect.gd
extends Area2D

@export var lifetime: float = 5.0  # Duration the aura effect will stay on screen

@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Optional, for fade or pulse animation

func _ready():
	# Start a timer to remove the aura effect after the duration
	#var timer = Timer.new()
	#timer.one_shot = true
	#timer.wait_time = lifetime
	#add_child(timer)
	#timer.timeout.connect(self.queue_free)

	# Play the aura animation, if available
	if animation_player:
		animation_player.play("aura_pulse")  # Assuming you have an "aura_pulse" animation
