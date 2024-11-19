# vendor.gd
extends AnimatedSprite2D

@export var max_shop_items: int = 5  # Number of random items to show in the shop
@onready var shop_ui = $Shop  # Reference to the shop UI
@onready var item_database = ItemDB  # Item database (autoload)

func _ready():
	print("Vendor ready, loaded item database.")

func interact():
	# Show the shop with random items
	var all_items = item_database.get_all_items()  # Get items from the ItemDatabase
	var random_items = get_random_items(all_items, max_shop_items)
	UI.open_mode(UI.MODE.SHOP, random_items)
	UI.set_buttons_transparency(false) 
	

# Close the shop and continue the game
func close_shop():
	get_tree().get_root().get_node("MainGame").close_shop()
	UI.set_buttons_transparency(true) 
	

# Get random items to display in the shop
func get_random_items(all_items: Array[Item], count: int) -> Array[Item]:
	var shuffled_items = all_items.duplicate()
	shuffled_items.shuffle()  # Shuffle the items
	return shuffled_items.slice(0, count)  # Pick the first `count` items
