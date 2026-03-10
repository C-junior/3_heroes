# wave_events.gd
extends Node
class_name WaveEvents

enum EventType {
	NONE,
	BLOOD_MOON,
	GOBLIN_AMBUSH,
	BLESSING_OF_LIGHT,
	ELITE_CHAMPION,
	TREASURE_WAVE
}

class WaveEvent:
	var type: EventType
	var title: String
	var description: String
	var color: Color
	
	func _init(p_type: EventType, p_title: String, p_desc: String, p_color: Color):
		type = p_type
		title = p_title
		description = p_desc
		color = p_color

var current_event: WaveEvent = null

# Roll a random event for the given wave
func roll_event(wave: int) -> WaveEvent:
	current_event = null
	
	# No events on wave 1 or boss wave (10)
	if wave <= 1 or wave >= 10:
		return null
	
	# 60% chance of an event on waves 3+
	if wave < 3 or randf() > 0.60:
		return null
	
	var possible_events: Array = []
	
	if wave >= 3:
		possible_events.append(WaveEvent.new(
			EventType.BLOOD_MOON,
			"🩸 BLOOD MOON",
			"Enemies deal +30% DMG but drop +50% gold!",
			Color(0.8, 0.1, 0.1)
		))
	
	if wave >= 4:
		possible_events.append(WaveEvent.new(
			EventType.GOBLIN_AMBUSH,
			"⚔️ GOBLIN AMBUSH",
			"+3 extra enemies spawn this wave!",
			Color(1, 0.5, 0)
		))
	
	if wave >= 2:
		possible_events.append(WaveEvent.new(
			EventType.BLESSING_OF_LIGHT,
			"✨ BLESSING OF LIGHT",
			"All heroes healed for 50% HP!",
			Color(1, 1, 0.5)
		))
	
	if wave >= 4:
		possible_events.append(WaveEvent.new(
			EventType.ELITE_CHAMPION,
			"💀 ELITE CHAMPION",
			"One enemy becomes an elite with 2x HP!",
			Color(0.6, 0.1, 0.8)
		))
	
	# Treasure wave is rare
	if wave >= 3 and randf() < 0.3:
		possible_events.append(WaveEvent.new(
			EventType.TREASURE_WAVE,
			"💰 TREASURE WAVE",
			"Fewer enemies, but each drops 3x gold!",
			Color(1, 0.85, 0)
		))
	
	if possible_events.is_empty():
		return null
	
	possible_events.shuffle()
	current_event = possible_events[0]
	return current_event

# Apply event effects to spawned enemies
func apply_event_to_enemies(enemies_node: Node, heroes_node: Node):
	if current_event == null:
		return
	
	match current_event.type:
		EventType.BLOOD_MOON:
			# +30% damage, +50% gold for all enemies
			for enemy in enemies_node.get_children():
				if enemy.has_method("apply_wave_scaling"):
					enemy.base_attack_damage = int(enemy.base_attack_damage * 1.3)
					enemy.min_gold_reward = int(enemy.min_gold_reward * 1.5)
					enemy.max_gold_reward = int(enemy.max_gold_reward * 1.5)
					enemy.update_stats()
					# Visual indicator - red tint
					var sprite = enemy.get("sprite")
					if sprite:
						sprite.modulate = Color(1, 0.5, 0.5)
		
		EventType.BLESSING_OF_LIGHT:
			# Heal all heroes 50%
			for hero in heroes_node.get_children():
				if hero.has_method("recover_between_waves"):
					hero.recover_between_waves(0.5)
		
		EventType.ELITE_CHAMPION:
			# Make one random enemy elite
			var enemies = enemies_node.get_children()
			if enemies.size() > 0:
				var elite = enemies[randi() % enemies.size()]
				elite.base_max_health *= 2
				elite.base_attack_damage = int(elite.base_attack_damage * 1.5)
				elite.min_gold_reward *= 3
				elite.max_gold_reward *= 3
				elite.xp_reward *= 2
				elite.update_stats()
				elite.current_health = elite.max_health
				# Visual indicator - purple + bigger
				var sprite = elite.get("sprite")
				if sprite:
					sprite.modulate = Color(0.8, 0.2, 1.0)
					sprite.scale *= 1.3
		
		EventType.TREASURE_WAVE:
			# All enemies drop 3x gold
			for enemy in enemies_node.get_children():
				enemy.min_gold_reward *= 3
				enemy.max_gold_reward *= 3
				# Visual indicator - gold tint
				var sprite = enemy.get("sprite")
				if sprite:
					sprite.modulate = Color(1, 0.85, 0)

# Get extra enemies to spawn for the Goblin Ambush event
func get_ambush_extras() -> Array:
	if current_event and current_event.type == EventType.GOBLIN_AMBUSH:
		return [{"scene_path": "res://Enemies/goblin.tscn", "count": 3}]
	return []
