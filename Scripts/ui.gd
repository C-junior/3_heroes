# ui.gd
# Complete UI for the incremental defense game
extends CanvasLayer

# --- Top Bar References ---
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var gold_label: Label = $TopBar/GoldLabel
@onready var token_label: Label = $TopBar/TokenLabel
@onready var unit_count_label: Label = $TopBar/UnitCountLabel
@onready var base_hp_bar: ProgressBar = $TopBar/BaseHPBar
@onready var base_hp_label: Label = $TopBar/BaseHPBar/BaseHPLabel

# --- Bottom Bar References ---
@onready var start_wave_btn: Button = $BottomBar/StartWaveButton
@onready var speed_1x_btn: Button = $BottomBar/SpeedButtons/Speed1x
@onready var speed_2x_btn: Button = $BottomBar/SpeedButtons/Speed2x
@onready var speed_3x_btn: Button = $BottomBar/SpeedButtons/Speed3x
@onready var recruit_btn: Button = $BottomBar/RecruitButton
@onready var shop_btn: Button = $BottomBar/ShopButton
@onready var repair_btn: Button = $BottomBar/RepairButton

# --- Panels ---
@onready var recruitment_panel: PanelContainer = $RecruitmentPanel
@onready var recruit_list: VBoxContainer = $RecruitmentPanel/MarginContainer/VBoxContainer/RecruitList
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var victory_panel: PanelContainer = $VictoryPanel
@onready var skill_popup: PanelContainer = $SkillUnlockPopup

# Game references
var main_game: Node2D
var base_node: Base

func _ready():
	# Wait a frame for everything to initialize
	await get_tree().process_frame
	
	main_game = get_tree().current_scene
	if main_game:
		base_node = main_game.get_node_or_null("Base")
		
		# Connect game signals
		main_game.connect("wave_started", Callable(self, "_on_wave_started"))
		main_game.connect("wave_completed", Callable(self, "_on_wave_completed"))
		main_game.connect("game_over", Callable(self, "_on_game_over"))
		main_game.connect("victory", Callable(self, "_on_victory"))
		
		# Connect base signals
		if base_node:
			base_node.connect("base_damaged", Callable(self, "_on_base_damaged"))
	
	# Connect GameManager signals
	GameManager.connect("gold_changed", Callable(self, "_on_gold_changed"))
	GameManager.connect("tokens_changed", Callable(self, "_on_tokens_changed"))
	
	# Connect buttons
	start_wave_btn.connect("pressed", Callable(self, "_on_start_wave_pressed"))
	speed_1x_btn.connect("pressed", Callable(self, "_on_speed_1x"))
	speed_2x_btn.connect("pressed", Callable(self, "_on_speed_2x"))
	speed_3x_btn.connect("pressed", Callable(self, "_on_speed_3x"))
	recruit_btn.connect("pressed", Callable(self, "_on_recruit_pressed"))
	shop_btn.connect("pressed", Callable(self, "_on_shop_pressed"))
	repair_btn.connect("pressed", Callable(self, "_on_repair_pressed"))
	
	# Hide panels
	recruitment_panel.visible = false
	game_over_panel.visible = false
	victory_panel.visible = false
	skill_popup.visible = false
	
	# Initialize UI
	_update_all_ui()
	_set_preparation_mode(true)

func _process(_delta: float):
	# Update HP bar continuously
	if base_node:
		base_hp_bar.value = base_node.get_health_percent() * 100.0
		base_hp_label.text = str(base_node.current_health) + " / " + str(base_node.base_max_health)

# --- UI Updates ---
func _update_all_ui():
	_on_gold_changed(GameManager.gold)
	_on_tokens_changed(GameManager.recruitment_tokens)
	wave_label.text = "Wave: " + str(GameManager.current_wave)
	_update_unit_count()
	if base_node:
		base_hp_bar.value = base_node.get_health_percent() * 100.0

func _update_unit_count():
	if main_game and main_game.unit_manager:
		var count = main_game.unit_manager.get_unit_count()
		var max_u = GameManager.get_max_units()
		unit_count_label.text = "Units: " + str(count) + "/" + str(max_u)

func _on_gold_changed(new_amount: int):
	gold_label.text = "Gold: " + str(new_amount)

func _on_tokens_changed(new_amount: int):
	token_label.text = "Tokens: " + str(new_amount)

# --- Game State UI ---
func _set_preparation_mode(preparing: bool):
	start_wave_btn.visible = preparing
	recruit_btn.visible = preparing
	shop_btn.visible = preparing
	repair_btn.visible = preparing

func _on_wave_started(wave_number: int):
	wave_label.text = "Wave: " + str(wave_number)
	_set_preparation_mode(false)
	recruitment_panel.visible = false

func _on_wave_completed(wave_number: int):
	wave_label.text = "Wave " + str(wave_number) + " Cleared!"
	_set_preparation_mode(true)
	_update_unit_count()

func _on_base_damaged(current_hp: int, max_hp: int):
	base_hp_bar.value = (float(current_hp) / float(max_hp)) * 100.0
	base_hp_label.text = str(current_hp) + " / " + str(max_hp)

# --- Game Over / Victory ---
func _on_game_over():
	game_over_panel.visible = true
	game_over_panel.process_mode = Node.PROCESS_MODE_ALWAYS # Ensure buttons work
	_set_preparation_mode(false)
	get_tree().paused = true # Pause game logic behind
	var stats_label = game_over_panel.get_node_or_null("MarginContainer/VBoxContainer/StatsLabel")
	if stats_label:
		var medals = GameManager.calculate_medals_earned()
		stats_label.text = "Wave Reached: " + str(GameManager.current_wave) + "\nMedals Earned: " + str(medals)

func _on_victory():
	victory_panel.visible = true
	victory_panel.process_mode = Node.PROCESS_MODE_ALWAYS # Ensure buttons work
	_set_preparation_mode(false)
	get_tree().paused = true # Pause game logic behind

# --- Button Handlers ---
func _on_start_wave_pressed():
	if main_game:
		main_game.start_wave()

func _on_speed_1x():
	Engine.time_scale = 1.0
func _on_speed_2x():
	Engine.time_scale = 2.0
func _on_speed_3x():
	Engine.time_scale = 3.0

func _on_recruit_pressed():
	recruitment_panel.visible = !recruitment_panel.visible
	if recruitment_panel.visible:
		_populate_recruitment_panel()

func _on_shop_pressed():
	if main_game:
		var vendor = main_game.get_node_or_null("Vendor")
		if vendor:
			vendor.interact()

func _on_repair_pressed():
	if base_node:
		var cost = base_node.get_repair_cost()
		if base_node.repair_with_gold():
			print("Base repaired! Cost: ", cost, " gold")
		else:
			print("Not enough gold! Need: ", cost)

# --- Recruitment Panel ---
func _populate_recruitment_panel():
	if not main_game or not main_game.unit_manager:
		return
	
	# Clear existing buttons
	for child in recruit_list.get_children():
		child.queue_free()
	
	var available = main_game.unit_manager.get_available_recruits()
	for recruit_data in available:
		var btn = Button.new()
		btn.text = recruit_data["name"] + " (Cost: " + str(recruit_data["token_cost"]) + " tokens)"
		btn.tooltip_text = recruit_data["description"]
		
		if not recruit_data["can_afford"] or not recruit_data["has_space"]:
			btn.disabled = true
			if not recruit_data["has_space"]:
				btn.text += " [MAX]"
			else:
				btn.text += " [NO TOKENS]"
		
		btn.connect("pressed", Callable(self, "_on_recruit_unit").bind(recruit_data["name"]))
		
		# Style the button
		btn.custom_minimum_size = Vector2(280, 40)
		recruit_list.add_child(btn)

func _on_recruit_unit(unit_name: String):
	if main_game and main_game.unit_manager:
		var player_chars = main_game.get_node("PlayerCharacters")
		if main_game.unit_manager.recruit_unit(unit_name, player_chars):
			_populate_recruitment_panel()
			_update_unit_count()
			print("Recruited: ", unit_name)

# --- Prestige ---
func _on_prestige_pressed():
	get_tree().paused = false # Unpause before reloading
	GameManager.prestige()
	# Reload the scene for a fresh run
	get_tree().reload_current_scene()

func _on_continue_pressed():
	victory_panel.visible = false
	get_tree().paused = false # Unpause
	_set_preparation_mode(true)
	# Allow continued play past Wave 30

# --- Skill Unlock (called externally) ---
func show_skill_unlock(unit: BaseCharacter, skills: Array):
	if skills.size() == 0:
		return
	get_tree().paused = true
	skill_popup.visible = true
	
	var skill_list = skill_popup.get_node_or_null("MarginContainer/VBoxContainer/SkillList")
	if not skill_list:
		return
	
	# Clear old
	for child in skill_list.get_children():
		child.queue_free()
	
	# Title
	var title = skill_popup.get_node_or_null("MarginContainer/VBoxContainer/TitleLabel")
	if title:
		title.text = unit.name + " — Choose a Skill!"
	
	for skill in skills:
		var btn = Button.new()
		btn.text = skill.name + ": " + skill.description
		btn.custom_minimum_size = Vector2(350, 45)
		btn.connect("pressed", Callable(self, "_on_skill_chosen").bind(unit, skill))
		skill_list.add_child(btn)

func _on_skill_chosen(unit: BaseCharacter, skill: Skill):
	unit.learn_skill(skill)
	skill_popup.visible = false
	get_tree().paused = false
	print(unit.name, " learned: ", skill.name)
