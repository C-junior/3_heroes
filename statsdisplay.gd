# StatsDisplay.gd
extends PanelContainer

@onready var speed_label = $"VBoxContainer/SpeedLabel"
@onready var health_label = $"VBoxContainer/HealthLabel"
@onready var attack_speed_label = $"VBoxContainer/AttackSpeedLabel"
@onready var attack_label: RichTextLabel = $VBoxContainer/AttackLabel
@onready var defense_label: RichTextLabel = $VBoxContainer/DefenseLabel
@onready var name_label: RichTextLabel = $VBoxContainer/Name


func _ready():
	pass

# Update the stats for the character passed to this function
func update_stats(character):
	if character == null:
		print("No character selected")
		return

	var attack_label = $VBoxContainer.get_node("AttackLabel")
	var defense_label = $VBoxContainer.get_node("DefenseLabel")
	var speed_label = $VBoxContainer.get_node("SpeedLabel")
	var health_label = $VBoxContainer.get_node("HealthLabel")
	var attack_speed_label = $VBoxContainer.get_node("AttackSpeedLabel")
	
	if name_label:
		name_label.bbcode_text = "   [b]Class:[/b] " + str(character.name)
	if attack_label:
		attack_label.bbcode_text = "   [b]ATK:[/b] " + str(character.attack_damage)
	if defense_label:
		defense_label.bbcode_text = "   [b]DEF:[/b] " + str(character.defense)
	if speed_label:
		speed_label.bbcode_text = "   [b]SPD:[/b] " + str(character.move_speed)
	if health_label:
		health_label.bbcode_text = "   [b]HP:[/b] " + str(character.current_health) + "/" + str(character.max_health)
	if attack_speed_label:
		var attacks_per_second = snappedf(1.0 / max(character.attack_cooldown, 0.01), 0.01)
		attack_speed_label.bbcode_text = "   [b]APS:[/b] %.2f" % attacks_per_second
	else:
		print("Labels not updated correctly")
