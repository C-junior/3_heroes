extends CanvasLayer

@onready var inventory: Inventory = %Inventory   # Shared inventory to display the active character's items
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

func _ready():
	_resolve_scene_refs()
	if wave_manager == null:
		push_warning("UI could not find MainGame node.")
		return
	# Listen for the wave signal to trigger skill selection
	wave_manager.connect("wave_skill_popup", Callable(self, "_show_skill_selection"))
	
	# Hide the skill panel initially
	skill_panel.visible = false
	skill_panel.process_mode = Node.PROCESS_MODE_ALWAYS  # Allow skill panel to work when paused

	if valkyrie:
		switch_to_character(valkyrie)
	set_buttons_transparency(true)

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

	if cleric:
		_setup_skill_buttons(cleric_buttons, SkillDB.get_skills_for_level(cleric.character_type, skill_tier, _get_learned_skill_names(cleric)), "cleric")
	if valkyrie:
		_setup_skill_buttons(valkyrie_buttons, SkillDB.get_skills_for_level(valkyrie.character_type, skill_tier, _get_learned_skill_names(valkyrie)), "valkyrie")
	if wizard:
		_setup_skill_buttons(wizard_buttons, SkillDB.get_skills_for_level(wizard.character_type, skill_tier, _get_learned_skill_names(wizard)), "wizard")



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
