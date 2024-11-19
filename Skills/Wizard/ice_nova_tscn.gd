extends Area2D

@export var damage: int = 50  # Base damage of the Ice Nova
@export var slow_duration: float = 2.0  # Duration enemies are slowed
@export var slow_percentage: float = 0.5  # 50% speed reduction
@onready var sprite = $AnimatedSprite2D  # Reference to the sprite for animation
@onready var effect_timer: Timer = Timer.new()

func _ready():
	# Add and start a timer for the Ice Nova's duration
	effect_timer.one_shot = true
	effect_timer.wait_time = slow_duration
	add_child(effect_timer)
	effect_timer.start()
	effect_timer.timeout.connect(self.queue_free)  # Remove Ice Nova when timer finishes

	# Play the ice nova animation
	sprite.play("ice_nova")
	# Connect the area_entered signal to detect when enemies enter the Ice Nova area
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body is an enemy and apply damage and slow
	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if body.has_method("apply_slow"):
			body.apply_slow(slow_percentage, slow_duration)
		print("Ice Nova applied to:", body.name)
