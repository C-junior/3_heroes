extends PanelContainer

@export var offset: Vector2 = Vector2(10, 10)  # Offset from mouse position
@onready var rich_text_label = $RichTextLabel  # Ensure this path matches your node structure

# Method to update tooltip text with BBCode formatting
func update_tooltip_text(text: String):
	if rich_text_label:
		rich_text_label.bbcode_text = text
	else:
		print("RichTextLabel not found in Tooltip.tscn. Check the node structure.")

# Continuously update the tooltip position based on the mouse location
func _process(delta: float):
	if get_viewport():  # Ensure get_viewport() is valid
		global_position = get_viewport().get_mouse_position() + offset
	else:
		print("Viewport not initialized.")
