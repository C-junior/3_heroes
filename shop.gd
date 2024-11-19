# shop.gd
extends Inventory

@onready var close_button = $"../CloseButton"  # Reference to the Close Button
@onready var reroll_button: Button = $"../RerollButton"
@onready var item_database = ItemDB  # Item database (autoload)
@onready var manager = global
@onready var vendor = get_tree().get_root().get_node("MainGame/Vendor")

@export var items : Array[Item] = []

func _ready():
	if vendor == null:
		print("Vendor node not found!")
	load_items(items)

func load_items(items):
	reset()
	for item in items:
		add_item(item)

func reset():
	for slot in get_children():
		slot.item = null
	

#func buy_item(item: Item, character: BaseCharacter):
	#print("buy item shop ", item, character)
	#if character.currency >= item.price:
		#character.currency -= item.price
		#character.inventory.append(item)
		#equip_item_to_character(character, item)
		#update_shop_ui()

func update_shop_ui():
	# Update the shop UI to reflect available items and player's currency
	pass

func _on_close_button_pressed() -> void:
	print("Closing shop...")
	close_shop()

func close_shop():
	var path = get_tree().get_root().get_node("MainGame/Vendor")
	if path != null:
		path.close_shop()
	else:
		print("Vendor node not found!")

func _on_reroll_button_pressed():
	manager.currency -= 20
	var all_items = item_database.get_all_items()
	var new_items = vendor.get_random_items(all_items, 5)  # Fetch new items from item manager
	print("Rerolling items...", manager.currency)
	load_items(new_items)  # Load new items into the shop
	global._update_balance_ui()
