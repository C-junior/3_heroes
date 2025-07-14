# character_base.gd
extends CharacterBody2D
class_name BaseCharacter

@export var health: int = 100
@export var max_health: int = 100
@export var attack: int = 10
@export var defense: int = 5

var current_item: Item

func equip_item(item: Item):
    if can_equip(item):
        current_item = item
        apply_item_stats(item)

func unequip_item(item: Item):
    if current_item == item:
        remove_item_stats(item)
        current_item = null

func can_equip(item: Item) -> bool:
    # Add logic here to check if the character can equip the item.
    # For example, check the item type or the character's class.
    return true

func apply_item_stats(item: Item):
    health += item.health_bonus
    max_health += item.health_bonus
    attack += item.attack_bonus
    defense += item.defense_bonus

func remove_item_stats(item: Item):
    health -= item.health_bonus
    max_health -= item.health_bonus
    attack -= item.attack_bonus
    defense -= item.defense_bonus
