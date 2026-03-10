# ui.gd
extends CanvasLayer
class_name UI

@onready var inventory: GridContainer = %Inventory   # Shared inventory to display the active character's items
@onready var balance_label: Label = %Balance

@onready var cleric_button: Button = %cleric_button
@onready var valkyrie_button: Button = %valkyrie_button
@onready var wizard_button: Button = %wizard_button  # Add wizard button
@onready var inventory_switch: Panel = $Inventory_switch
@onready var ativechar: Button = $Inventory_switch/ativechar

# Skill Panel
@onready var cleric_buttons = $SkillPanel/SkillPopupCleric  # HBox for Cleric skills
@onready var valkyrie_buttons = $SkillPanel/SkillPopupValkyrie  # HBox for Valkyrie skills
@onready var wizard_buttons = $SkillPanel/SkillPopupWizard  # HBox for Wizard skills
@onready var confirm_button = $SkillPanel/ConfirmButton  # Confirm button
@onready var skill_panel = $SkillPanel  # The whole skill panel

@onready var stats_display: PanelContainer = %StatsDisplay

var wave_manager: Node = null
var cleric: BaseCharacter = null
var valkyrie: BaseCharacter = null
var wizard: BaseCharacter = null

var skills_selected_cleric = false
var skills_selected_valkyrie = false
var skills_selected_wizard = false

# Signal to notify which character is selected
signal character_switched(character: BaseCharacter)

# Tracks the active character
var active_character: BaseCharacter = null

# ---- NEW: Shop, Events, Game End UI ----
var shop_panel: PanelContainer = null
var shop_items_container: VBoxContainer = null
var event_banner: Label = null
var game_end_panel: PanelContainer = null
var kill_counter_label: Label = null
var reroll_buttons: Dictionary = {}  # hero_name -> Button

# Track references to systems
var shop_system: ShopSystem = null
var current_dead_heroes: Array = []

func _ready():
	_resolve_scene_refs()
	if wave_manager == null:
		push_warning("UI could not find MainGame node.")
		return
	# Listen for the wave signal to trigger skill selection
	wave_manager.connect("wave_skill_popup", Callable(self, "_show_skill_selection"))
	
	# Connect new signals
	if wave_manager.has_signal("game_over"):
		wave_manager.connect("game_over", Callable(self, "_show_game_over"))
	if wave_manager.has_signal("victory"):
		wave_manager.connect("victory", Callable(self, "_show_victory"))
	if wave_manager.has_signal("wave_event_triggered"):
		wave_manager.connect("wave_event_triggered", Callable(self, "_show_event_banner"))
	if wave_manager.has_signal("show_shop"):
		wave_manager.connect("show_shop", Callable(self, "_on_show_shop"))
	
	# Get shop system reference
	shop_system = wave_manager.get_node_or_null("ShopSystem")
	if shop_system == null:
		# It might be added as a child at runtime, try finding it
		for child in wave_manager.get_children():
			if child is ShopSystem:
				shop_system = child
				break
	
	# Hide the skill panel initially
	skill_panel.visible = false
	skill_panel.process_mode = Node.PROCESS_MODE_ALWAYS  # Allow skill panel to work when paused

	if valkyrie:
		switch_to_character(valkyrie)
	set_buttons_transparency(true)
	
	# Create dynamic UI elements
	_create_shop_panel()
	_create_event_banner()
	_create_game_end_panel()
	_create_kill_counter()
	_create_reroll_buttons()

func _resolve_scene_refs():
	var scene_root = get_tree().current_scene
	if scene_root == null:
		return
	wave_manager = scene_root.get_node_or_null("MainGame")
	if wave_manager == null:
		return
	cleric = wave_manager.get_node_or_null("PlayerCharacters/Cleric")
	valkyrie = wave_manager.get_node_or_null("PlayerCharacters/Valkyrie")
	wizard = wave_manager.get_node_or_null("PlayerCharacters/Wizard")

enum MODE {
	INVENTORY,
	SHOP
}

func set_buttons_transparency(transparent: bool):
	var transparency = Color(1, 1, 1, 1)  # Full opacity
	if transparent:
		transparency.a = 0  # Make fully transparent

	cleric_button.modulate = transparency
	valkyrie_button.modulate = transparency
	wizard_button.modulate = transparency
	inventory_switch.modulate = transparency

func open_mode(mode, items):
	%Shop.load_items(items)
	$Manager.open_mode(mode)


# Called when the Cleric button is pressed
func _on_cleric_button_pressed():
	if cleric:
		switch_to_character(cleric)
		ativechar.text = "Cleric"

# Called when the Valkyrie button is pressed
func _on_valkyrie_button_pressed() -> void:
	if valkyrie:
		switch_to_character(valkyrie)
		ativechar.text = "Valkyrie"

# Called when the Wizard button is pressed
func _on_wizard_button_pressed() -> void:
	if wizard:
		switch_to_character(wizard)
		ativechar.text = "Wizard"

# Function to switch to the selected character and update the shared inventory
func switch_to_character(character: BaseCharacter):
	if character == null:
		return
	active_character = character
	emit_signal("character_switched", active_character)

	# Update inventory display for the new character
	update_inventory_with_character_items(character)

	# Update stats display with the new active character's stats
	update_ui_stats()

	print("Switched to character:", active_character.name)

func update_inventory_with_character_items(character: BaseCharacter):
	if character == null:
		return
	# Clear the inventory slots first
	for slot in inventory.get_children():
		slot.item = null

	# Add equipped items back to their respective slots
	var equipped_items = character.get("equipped_items")
	if character.has_method("can_equip") and equipped_items != null:
		for slot_name in character.equipped_items.keys():
			var item = character.equipped_items[slot_name]
			if item != null and character.can_equip(item):
				if slot_name == "weapon":
					inventory.get_children()[0].item = item
				elif slot_name == "armor":
					inventory.get_children()[1].item = item
				elif slot_name == "accessory":
					inventory.get_children()[2].item = item

	# Call update_ui_stats to refresh stats display when items are equipped
	update_ui_stats()

# Function to update stats using the active character
func update_ui_stats():
	if stats_display and active_character:
		stats_display.update_stats(active_character)
		

# Show skill selection after each wave
func _show_skill_selection():
	_resolve_scene_refs()
	get_tree().paused = true  # Pause the game
	skill_panel.visible = true  # Show the skill panel
	confirm_button.visible = false
	confirm_button.disabled = true

	# Reset skill selection flags
	skills_selected_cleric = false
	skills_selected_valkyrie = false
	skills_selected_wizard = false

	# Load skills for each character from SkillDatabase
	var current_wave_level = max(wave_manager.current_wave, 1)
	var skill_tier = wave_manager.get_skill_tier_for_wave(current_wave_level)
	confirm_button.text = "Start Wave %d" % current_wave_level

	if cleric and not cleric.is_dead:
		_setup_skill_buttons(cleric_buttons, SkillDB.get_skills_for_level(cleric.character_type, skill_tier, _get_learned_skill_names(cleric)), "cleric")
		cleric_buttons.visible = true
		if reroll_buttons.has("cleric"):
			reroll_buttons["cleric"].visible = true
			_update_reroll_button("cleric")
	else:
		cleric_buttons.visible = false
		skills_selected_cleric = true  # Skip dead hero
		if reroll_buttons.has("cleric"):
			reroll_buttons["cleric"].visible = false
	
	if valkyrie and not valkyrie.is_dead:
		_setup_skill_buttons(valkyrie_buttons, SkillDB.get_skills_for_level(valkyrie.character_type, skill_tier, _get_learned_skill_names(valkyrie)), "valkyrie")
		valkyrie_buttons.visible = true
		if reroll_buttons.has("valkyrie"):
			reroll_buttons["valkyrie"].visible = true
			_update_reroll_button("valkyrie")
	else:
		valkyrie_buttons.visible = false
		skills_selected_valkyrie = true  # Skip dead hero
		if reroll_buttons.has("valkyrie"):
			reroll_buttons["valkyrie"].visible = false
	
	if wizard and not wizard.is_dead:
		_setup_skill_buttons(wizard_buttons, SkillDB.get_skills_for_level(wizard.character_type, skill_tier, _get_learned_skill_names(wizard)), "wizard")
		wizard_buttons.visible = true
		if reroll_buttons.has("wizard"):
			reroll_buttons["wizard"].visible = true
			_update_reroll_button("wizard")
	else:
		wizard_buttons.visible = false
		skills_selected_wizard = true  # Skip dead hero
		if reroll_buttons.has("wizard"):
			reroll_buttons["wizard"].visible = false
	
	# Show shop panel if we have shop items
	if shop_panel and shop_system and shop_system.current_inventory.size() > 0:
		_refresh_shop_panel()
		shop_panel.visible = true
	
	# Check if all alive heroes already have skills selected (edge case)
	_check_all_skills_selected()



# Setup skill buttons with icons and descriptions for specific characters
func _setup_skill_buttons(buttons_container: HBoxContainer, skills: Array, character_type: String):
	# Safely disconnect previous signals
	for button in buttons_container.get_children():
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)
		button.disabled = false  # Re-enable buttons
		button.visible = true
	
	# Set up new skills
	for i in range(buttons_container.get_child_count()):
		var button = buttons_container.get_child(i)
		if i >= skills.size():
			button.visible = false
			continue
		var skill = skills[i]
		button.text = skill.name
		button.icon = skill.icon
		button.tooltip_text = _build_skill_tooltip(skill)
		button.connect("pressed", Callable(self, "_on_skill_selected").bind(buttons_container, skill, character_type))

# When a skill is selected for any character
func _on_skill_selected(buttons_container: HBoxContainer, skill: Skill, character_type: String):
	if character_type == "cleric" and cleric:
		cleric.learn_skill(skill)
		skills_selected_cleric = true
		print("Cleric learned skill:", skill.name)
	elif character_type == "valkyrie" and valkyrie:
		valkyrie.learn_skill(skill)
		skills_selected_valkyrie = true
		print("Valkyrie learned skill:", skill.name)
	elif character_type == "wizard" and wizard:
		wizard.learn_skill(skill)
		skills_selected_wizard = true
		print("Wizard learned skill:", skill.name)

	_disable_skill_buttons(buttons_container)
	# Hide reroll button after selection
	if reroll_buttons.has(character_type):
		reroll_buttons[character_type].visible = false
	_check_all_skills_selected()

# Enable skill buttons
func _enable_skill_buttons(buttons_container: HBoxContainer):
	for button in buttons_container.get_children():
		button.disabled = false

# Disable skill buttons after selection
func _disable_skill_buttons(buttons_container: HBoxContainer):
	for button in buttons_container.get_children():
		button.disabled = true

# Check if at least one character has selected a skill (more flexible for fun gameplay)
func _check_all_skills_selected():
	var all_selected = skills_selected_cleric and skills_selected_valkyrie and skills_selected_wizard
	confirm_button.visible = all_selected
	confirm_button.disabled = not all_selected

# Confirm skill selections and resume the game
func _on_confirm_skills():
	get_tree().paused = false  # Unpause the game
	skill_panel.visible = false  # Hide the skill panel
	if shop_panel:
		shop_panel.visible = false
	_reset_skill_buttons()
	print("Skills confirmed. Resuming game.")
	
	# Notify main game that skills are confirmed
	if wave_manager.has_method("on_skills_confirmed"):
		wave_manager.on_skills_confirmed()

# Reset the skill buttons for the next selection
func _reset_skill_buttons():
	for button in cleric_buttons.get_children():
		button.disabled = false
		button.visible = true
	for button in valkyrie_buttons.get_children():
		button.disabled = false
		button.visible = true
	for button in wizard_buttons.get_children():
		button.disabled = false
		button.visible = true

func _on_confirm_button_pressed() -> void:
	_on_confirm_skills()
	
func _process(delta: float) -> void:
	update_ui_stats()
	balance_label.text = str(global.currency)
	
	# Update kill counter
	if kill_counter_label and wave_manager:
		kill_counter_label.text = "Kills: %d" % wave_manager.total_kills

func _get_learned_skill_names(character: BaseCharacter) -> Array:
	var learned_names: Array = []
	if character == null:
		return learned_names
	for skill in character.learned_skills:
		learned_names.append(skill.name)
	return learned_names

func _build_skill_tooltip(skill: Skill) -> String:
	if skill.cooldown > 0.0:
		return "%s\nCooldown: %.1fs" % [skill.description, skill.cooldown]
	return skill.description


# ============================================================
# SHOP PANEL (Built dynamically in code)
# ============================================================

func _create_shop_panel():
	shop_panel = PanelContainer.new()
	shop_panel.name = "ShopPanel"
	shop_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.10, 0.18, 0.95)
	style.border_color = Color(0.85, 0.65, 0.15)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	shop_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.name = "ShopVBox"
	shop_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "⚔️ SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.85, 0.65, 0.15))
	vbox.add_child(title)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	shop_items_container = VBoxContainer.new()
	shop_items_container.name = "ShopItems"
	vbox.add_child(shop_items_container)
	
	shop_panel.visible = false
	
	# Position - right side
	shop_panel.anchors_preset = Control.PRESET_TOP_RIGHT
	shop_panel.position = Vector2(600, 50)
	shop_panel.custom_minimum_size = Vector2(220, 100)
	
	add_child(shop_panel)

func _refresh_shop_panel():
	if shop_items_container == null or shop_system == null:
		return
	
	# Clear old items
	for child in shop_items_container.get_children():
		child.queue_free()
	
	# Add each item as a button
	for item in shop_system.current_inventory:
		var btn = Button.new()
		btn.text = "%s (%dg)" % [item.item_name, item.cost]
		btn.tooltip_text = item.description
		btn.custom_minimum_size = Vector2(200, 35)
		
		# Color by affordability
		if global.currency >= item.cost:
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			btn.disabled = true
		
		# Determine which hero to apply to
		if item.item_type == "revive":
			btn.connect("pressed", Callable(self, "_on_shop_buy_revive").bind(item))
		else:
			btn.connect("pressed", Callable(self, "_on_shop_buy_for_active").bind(item))
		
		shop_items_container.add_child(btn)

func _on_shop_buy_for_active(item):
	if active_character == null or active_character.is_dead:
		print("Select an alive hero first!")
		return
	
	if shop_system and shop_system.buy_item(item, active_character):
		# Remove item from inventory and refresh
		shop_system.current_inventory.erase(item)
		_refresh_shop_panel()
		update_ui_stats()

func _on_shop_buy_revive(item):
	if wave_manager == null:
		return
	
	# Find first dead hero to revive
	var dead = wave_manager.dead_heroes
	if dead.is_empty():
		print("No dead heroes to revive!")
		return
	
	var hero_to_revive = dead[0]
	if shop_system and global.currency >= item.cost:
		global.currency -= item.cost
		wave_manager.revive_hero(hero_to_revive)
		shop_system.current_inventory.erase(item)
		_refresh_shop_panel()
		# Re-show skill selection since hero is back
		_show_skill_selection()


# ============================================================
# REROLL BUTTONS
# ============================================================

func _create_reroll_buttons():
	# Create a reroll button for each hero, placed near their skill row
	var heroes = {"cleric": cleric_buttons, "valkyrie": valkyrie_buttons, "wizard": wizard_buttons}
	for hero_name in heroes.keys():
		var btn = Button.new()
		btn.name = "Reroll_" + hero_name
		btn.text = "🔄 Reroll (20g)"
		btn.custom_minimum_size = Vector2(130, 30)
		btn.process_mode = Node.PROCESS_MODE_ALWAYS
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", Color(0.85, 0.65, 0.15))
		btn.visible = false
		
		btn.connect("pressed", Callable(self, "_on_reroll_pressed").bind(hero_name))
		
		# Add after the skill buttons container
		var parent = heroes[hero_name].get_parent()
		if parent:
			parent.add_child(btn)
		else:
			skill_panel.add_child(btn)
		
		reroll_buttons[hero_name] = btn

func _update_reroll_button(hero_name: String):
	if not reroll_buttons.has(hero_name) or shop_system == null:
		return
	var cost = shop_system.get_reroll_cost(hero_name)
	var btn = reroll_buttons[hero_name]
	btn.text = "🔄 Reroll (%dg)" % cost
	btn.disabled = global.currency < cost

func _on_reroll_pressed(hero_name: String):
	if shop_system == null:
		return
	
	if not shop_system.do_reroll(hero_name):
		return
	
	# Re-randomize the skills for this hero
	var current_wave_level = max(wave_manager.current_wave, 1)
	var skill_tier = wave_manager.get_skill_tier_for_wave(current_wave_level)
	
	match hero_name:
		"cleric":
			if cleric:
				skills_selected_cleric = false
				_setup_skill_buttons(cleric_buttons, SkillDB.get_skills_for_level(cleric.character_type, skill_tier, _get_learned_skill_names(cleric)), "cleric")
		"valkyrie":
			if valkyrie:
				skills_selected_valkyrie = false
				_setup_skill_buttons(valkyrie_buttons, SkillDB.get_skills_for_level(valkyrie.character_type, skill_tier, _get_learned_skill_names(valkyrie)), "valkyrie")
		"wizard":
			if wizard:
				skills_selected_wizard = false
				_setup_skill_buttons(wizard_buttons, SkillDB.get_skills_for_level(wizard.character_type, skill_tier, _get_learned_skill_names(wizard)), "wizard")
	
	_update_reroll_button(hero_name)
	_check_all_skills_selected()


# ============================================================
# EVENT BANNER
# ============================================================

func _create_event_banner():
	event_banner = Label.new()
	event_banner.name = "EventBanner"
	event_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	event_banner.add_theme_font_size_override("font_size", 22)
	event_banner.anchors_preset = Control.PRESET_CENTER_TOP
	event_banner.position = Vector2(200, 40)
	event_banner.custom_minimum_size = Vector2(400, 50)
	event_banner.visible = false
	add_child(event_banner)

func _show_event_banner(event):
	if event_banner == null or event == null:
		return
	event_banner.text = event.title + "\n" + event.description
	event_banner.add_theme_color_override("font_color", event.color)
	event_banner.visible = true
	
	# Auto-hide after 3 seconds
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	if event_banner:
		event_banner.visible = false


# ============================================================
# GAME END PANEL (Game Over / Victory)
# ============================================================

func _create_game_end_panel():
	game_end_panel = PanelContainer.new()
	game_end_panel.name = "GameEndPanel"
	game_end_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	style.border_color = Color(0.8, 0.2, 0.2)
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	game_end_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.name = "EndVBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	game_end_panel.add_child(vbox)
	
	# Title
	var title_label = Label.new()
	title_label.name = "EndTitle"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title_label)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Stats
	var stats_label = Label.new()
	stats_label.name = "EndStats"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(stats_label)
	
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	# Play Again button
	var play_again = Button.new()
	play_again.name = "PlayAgainButton"
	play_again.text = "⚔️ Play Again"
	play_again.custom_minimum_size = Vector2(200, 45)
	play_again.add_theme_font_size_override("font_size", 18)
	play_again.connect("pressed", Callable(self, "_on_play_again"))
	vbox.add_child(play_again)
	
	# Quit button
	var quit_btn = Button.new()
	quit_btn.name = "QuitButton"
	quit_btn.text = "Quit"
	quit_btn.custom_minimum_size = Vector2(200, 35)
	quit_btn.connect("pressed", Callable(self, "_on_quit"))
	vbox.add_child(quit_btn)
	
	game_end_panel.anchors_preset = Control.PRESET_CENTER
	game_end_panel.position = Vector2(200, 100)
	game_end_panel.custom_minimum_size = Vector2(350, 250)
	game_end_panel.visible = false
	
	add_child(game_end_panel)

func _show_game_over(stats: Dictionary):
	get_tree().paused = true
	skill_panel.visible = false
	if shop_panel:
		shop_panel.visible = false
	
	if game_end_panel:
		game_end_panel.visible = true
		var title = game_end_panel.get_node("EndVBox/EndTitle")
		title.text = "💀 GAME OVER"
		title.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
		
		var stats_label = game_end_panel.get_node("EndVBox/EndStats")
		stats_label.text = "Wave Reached: %d\nEnemies Slain: %d\nHeroes Fallen: %d\nGold: %d" % [
			stats.get("wave_reached", 0),
			stats.get("total_kills", 0),
			stats.get("heroes_fallen", 0),
			global.currency
		]

func _show_victory(stats: Dictionary):
	get_tree().paused = true
	skill_panel.visible = false
	if shop_panel:
		shop_panel.visible = false
	
	if game_end_panel:
		game_end_panel.visible = true
		var style = game_end_panel.get_theme_stylebox("panel").duplicate()
		style.border_color = Color(0.85, 0.65, 0.15)
		game_end_panel.add_theme_stylebox_override("panel", style)
		
		var title = game_end_panel.get_node("EndVBox/EndTitle")
		title.text = "🏆 VICTORY!"
		title.add_theme_color_override("font_color", Color(0.85, 0.65, 0.15))
		
		var stats_label = game_end_panel.get_node("EndVBox/EndStats")
		stats_label.text = "All 10 Waves Cleared!\nEnemies Slain: %d\nHeroes Fallen: %d\nGold Remaining: %d" % [
			stats.get("total_kills", 0),
			stats.get("heroes_fallen", 0),
			global.currency
		]

func _on_play_again():
	get_tree().paused = false
	if wave_manager and wave_manager.has_method("restart_game"):
		wave_manager.restart_game()
	else:
		get_tree().reload_current_scene()

func _on_quit():
	get_tree().quit()


# ============================================================
# KILL COUNTER
# ============================================================

func _create_kill_counter():
	kill_counter_label = Label.new()
	kill_counter_label.name = "KillCounter"
	kill_counter_label.text = "Kills: 0"
	kill_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	kill_counter_label.add_theme_font_size_override("font_size", 16)
	kill_counter_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	kill_counter_label.position = Vector2(10, 10)
	add_child(kill_counter_label)
