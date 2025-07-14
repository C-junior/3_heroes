# ui_manager.gd
extends CanvasLayer
class_name UIManager

signal shop_closed

@onready var wave_label: Label = $WaveLabel
@onready var currency_label: Label = $Currency/Balance
@onready var shop_ui: Panel = $Shop

var game_state_manager: GameStateManager

func _ready():
    game_state_manager = get_node("/root/MainGame/GameStateManager")
    if game_state_manager == null:
        print("Error: GameStateManager not found!")
    else:
        update_currency_label()

    shop_ui.visible = false

func update_wave_label(wave_number: int):
    wave_label.text = "Wave " + str(wave_number)

func update_currency_label():
    if game_state_manager != null:
        currency_label.text = str(game_state_manager.currency)

func open_shop():
    shop_ui.visible = true

func close_shop():
    shop_ui.visible = false
    emit_signal("shop_closed")
