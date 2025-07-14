# mass_heal_effect.gd
extends Node2D

@export var endtime: float = 1.5  # Duration of the healing effect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Start a timer to remove the effect after its lifetime
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = endtime
	add_child(timer)
	timer.connect("timeout", Callable(self, "queue_free"))

	# Play the healing animation if available
	if animation_player:
		animation_player.play("heal")  # Ensure you have a "heal" animation in the AnimationPlayer
