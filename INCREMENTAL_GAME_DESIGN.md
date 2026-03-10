# 3 Heroes Stand: Incremental Defense Game Transformation

## 📋 Current Game Analysis

### Existing Architecture
- **Genre**: Wave-based action RPG with 3 heroes (Knight, Cleric, Valkyrie, Wizard)
- **Core Loop**: Fight waves → Earn gold/XP → Shop between waves → Stronger heroes
- **Features**:
  - 4 character classes with unique skills
  - 10 wave progression with increasing difficulty
  - Item system with weapon/armor/accessory slots
  - Skill system with active/passive abilities
  - Level system with XP rewards
  - Shop with reroll mechanics

### Current Limitations for Incremental Design
- ❌ Fixed 3 heroes from start (no progression feeling)
- ❌ Only 10 waves (too short for incremental)
- ❌ No base to defend (just survive)
- ❌ Skills learned immediately (no unlock progression)
- ❌ No recruitment system
- ❌ No meta-progression between runs
- ❌ Limited scaling potential

---

## 🎯 New Game Vision: "Base Defense Incremental"

### Core Concept
**Start with ONE weak defender → Recruit & expand → Unlock abilities through play → Defend base against endless waves → Meta-progression**

### Key Pillars
1. **Humble Beginnings**: Start with 1 basic unit, no skills
2. **Recruitment System**: Earn recruitment tokens to add more units
3. **Ability Unlocks**: Units gain abilities THROUGH gameplay, not at start
5. **Endless Scaling**: Infinite waves with exponential difficulty
6. **Prestige System**: Reset for permanent bonuses

---

## 🏗️ Architecture Transformation

### 1. Base System (NEW)

```gdscript
# base.gd (NEW)
extends Node2D
class_name Base

@export var max_health: int = 1000
@export var current_health: int
@export var defense: int = 10
@export var regeneration: int = 0  # HP per second

# Upgrade stats (prestige currency)
@export var max_health_multiplier: float = 1.0
@export var defense_multiplier: float = 1.0

signal base_destroyed
signal base_damaged(percent)

func take_damage(amount: int):
    var reduced_damage = max(amount - defense, 1)
    current_health -= reduced_damage
    emit_signal("base_damaged", current_health / max_health)
    
    if current_health <= 0:
        emit_signal("base_destroyed")

func repair(amount: int):
    current_health = min(current_health + amount, max_health)
```

**UI Elements Needed:**
- Base health bar (prominent, top of screen)
- Base defense stat display
- Repair button (cost: gold)
- Base upgrade panel (prestige currency)

---

### 2. Single Hero Start System

```gdscript
# unit_manager.gd (REPLACES party_manager)
extends Node
class_name UnitManager

@export var starting_unit_scene: PackedScene
@export var max_units: int = 8  # Can be upgraded

var units: Array[BaseCharacter] = []
var available_recruitment_slots: int = 0
var recruitment_tokens: int = 0  # Earned from waves

signal unit_recruited(unit)
signal recruitment_slot_unlocked()

func _ready():
    # Start with ONLY 1 unit
    spawn_starting_unit()

func spawn_starting_unit():
    var unit = starting_unit_scene.instantiate() as BaseCharacter
    add_unit(unit)

func add_unit(unit: BaseCharacter):
    if units.size() >= get_max_units():
        return false  # No space available
    
    units.append(unit)
    get_tree().current_scene.add_child(unit)
    
    # Position near base
    unit.position = Vector2(200 + (units.size() * 30), 240)
    emit_signal("unit_recruited", unit)
    return true

func recruit_unit(recruit_data: Dictionary):
    """Spend recruitment token to add new unit"""
    if recruitment_tokens <= 0:
        return false
    
    recruitment_tokens -= 1
    var new_unit = load(recruit_data.scene_path).instantiate() as BaseCharacter
    new_unit.character_class = recruit_data.character_class
    add_unit(new_unit)
    return true

func unlock_recruitment_slot():
    """Increase max unit capacity"""
    max_units += 1
    emit_signal("recruitment_slot_unlocked")
```

---

### 3. Recruitment Window System (NEW)

```gdscript
# recruitment_panel.gd (NEW)
extends Control
class_name RecruitmentPanel

@onready var unit_pool = [
    {
        "name": "Knight",
        "scene_path": "res://Scenes/knight.tscn",
        "character_class": Constants.CharacterType.FIGHTER,
        "cost": 1,  # Recruitment tokens
        "description": "High HP, melee tank"
    },
    {
        "name": "Cleric",
        "scene_path": "res://Scenes/cleric.tscn",
        "character_class": Constants.CharacterType.HEALER,
        "cost": 1,
        "description": "Heals nearby units"
    },
    {
        "name": "Wizard",
        "scene_path": "res://Scenes/wizard.tscn",
        "character_class": Constants.CharacterType.MAGE,
        "cost": 2,  # Harder to recruit
        "description": "Ranged AoE damage"
    },
    {
        "name": "Valkyrie",
        "scene_path": "res://Scenes/valkyrie.tscn",
        "character_class": Constants.CharacterType.HYBRID,
        "cost": 2,
        "description": "Balanced fighter with burst"
    }
]

var unit_manager: UnitManager

func _ready():
    unit_manager = get_tree().current_scene.get_node("UnitManager")
    update_pool_display()

func update_pool_display():
    """Show available recruits based on tokens"""
    for i, recruit in enumerate(unit_pool):
        var slot = get_node("UnitSlots/Slot" + str(i))
        slot.update_recruit(recruit, unit_manager.recruitment_tokens >= recruit.cost)

func recruit_button_pressed(index: int):
    var recruit = unit_pool[index]
    if unit_manager.recruitment_tokens >= recruit.cost:
        unit_manager.recruit_unit(recruit)
        update_pool_display()
```

**UI Layout:**
```
┌─────────────────────────────────┐
│   RECRUITMENT CENTER            │
│   Tokens Available: [3]         │
├─────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐        │
│ │  Knight │ │ Cleric  │        │
│ │ Cost: 1 │ │ Cost: 1 │        │
│ │ [Recruit]│ │[Recruit]│       │
│ └─────────┘ └─────────┘        │
│ ┌─────────┐ ┌─────────┐        │
│ │  Wizard │ │Valkyrie │        │
│ │ Cost: 2 │ │ Cost: 2 │        │
│ │ [Recruit]│ │[Recruit]│       │
│ └─────────┘ └─────────┘        │
└─────────────────────────────────┘
```

**How to Earn Recruitment Tokens:**
- Complete every 5th wave: +1 token
- Boss waves (10, 20, 30...): +2 tokens
- Achievement milestones: +1 token
- Prestige bonus: +1 token per run

---

### 4. Ability Unlock System (NEW)

```gdscript
# ability_unlock.gd (NEW)
extends Node
class_name AbilityUnlockSystem

# Define when abilities unlock (NOT at start!)
var ability_unlocks = {
    "Knight": {
        "level_3": ["Charge", "Defense Stance"],  # Unlock at level 3
        "level_7": ["Taunt", "Berserker Mode"],   # Unlock at level 7
        "level_15": ["Shield Bash"]                # Ultimate at 15
    },
    "Cleric": {
        "level_3": ["Healing Light"],
        "level_7": ["Purifying Wave"],
        "level_15": ["Resurrection"]
    },
    "Wizard": {
        "level_3": ["Fireball", "Haste"],
        "level_7": ["Chain Lightning"],
        "level_15": ["Meteor Strike"]
    },
    "Valkyrie": {
        "level_3": ["Spear Throw"],
        "level_7": ["Thunder Strike"],
        "level_15": ["Ragnarok"]
    }
}

signal ability_unlocked(unit, ability_name)

func check_unlocks(unit: BaseCharacter):
    """Check if unit unlocked new abilities based on level"""
    var class_name = unit.character_class
    var level = unit.level_system.level
    var unlocks = ability_unlocks.get(class_name, {})
    
    if level == 3:
        unlock_abilities(unit, unlocks.get("level_3", []))
    elif level == 7:
        unlock_abilities(unit, unlocks.get("level_7", []))
    elif level == 15:
        unlock_abilities(unit, unlocks.get("level_15", []))

func unlock_abilities(unit: BaseCharacter, abilities: Array):
    for ability_name in abilities:
        var skill = SkillDB.get_skill(ability_name)
        unit.learn_skill(skill)
        emit_signal("ability_unlocked", unit, ability_name)
        # Show popup: "Knight unlocked CHARGE!"
```

**Key Design Change:**
- ❌ OLD: Units start with all skills
- ✅ NEW: Units start with basic attack ONLY
- ✅ Skills unlock at levels 3, 7, 15 (creates progression feeling)
- ✅ Players feel units getting stronger THROUGH gameplay

---

### 5. Wave Manager Overhaul

```gdscript
# wave_manager.gd (OVERHAUL)
extends Node

# INFINITE wave scaling (not just 10 waves)
var wave_config = {
    "early_game": {  # Waves 1-10
        "enemy_base_hp": 100,
        "enemy_base_dmg": 10,
        "enemy_count_base": 3,
        "scaling_factor": 1.3
    },
    "mid_game": {  # Waves 11-50
        "enemy_base_hp": 500,
        "enemy_base_dmg": 35,
        "enemy_count_base": 8,
        "scaling_factor": 1.5
    },
    "late_game": {  # Waves 51-100
        "enemy_base_hp": 2000,
        "enemy_base_dmg": 100,
        "enemy_count_base": 15,
        "scaling_factor": 1.7
    },
    "endless": {  # Waves 101+
        "enemy_base_hp": 10000,
        "enemy_base_dmg": 500,
        "enemy_count_base": 25,
        "scaling_factor": 2.0
    }
}

func get_wave_enemies(wave_number: int) -> Array:
    var phase = get_wave_phase(wave_number)
    var config = wave_config[phase]
    
    # Calculate enemy stats with exponential scaling
    var hp_multiplier = pow(config.scaling_factor, wave_number - 1)
    var dmg_multiplier = pow(config.scaling_factor, wave_number - 1)
    
    var enemies = []
    var enemy_types = get_available_enemy_types(wave_number)
    
    for enemy_type in enemy_types:
        var count = calculate_enemy_count(wave_number, enemy_type)
        enemies.append({
            "scene_path": enemy_type.scene_path,
            "count": count,
            "hp_override": int(enemy_type.base_hp * hp_multiplier),
            "damage_override": int(enemy_type.base_dmg * dmg_multiplier)
        })
    
    return enemies

func get_wave_phase(wave: int) -> String:
    if wave <= 10: return "early_game"
    elif wave <= 50: return "mid_game"
    elif wave <= 100: return "late_game"
    else: return "endless"
```

**New Wave Rewards:**
```gdscript
# wave_rewards.gd (NEW)
func complete_wave(wave_number: int):
    # Base gold reward (scales with wave)
    var gold = int(50 * pow(1.1, wave_number))
    global.add_currency(gold)
    
    # Recruitment token every 5 waves
    if wave_number % 5 == 0:
        unit_manager.recruitment_tokens += 1
    
    # Boss waves give bonus
    if wave_number % 10 == 0:
        unit_manager.recruitment_tokens += 2
        grant_prestige_currency(1)
    
    # Healing base between waves
    base.repair(int(base.max_health * 0.1))
```

---

### 6. Main Game Flow Redesign

```gdscript
# main_game.gd (OVERHAUL)
extends Node2D

@export var base_scene: PackedScene
@export var unit_manager: UnitManager

var current_wave = 1
var wave_in_progress = false
var base: Base

enum GameState {
    PREPARATION,  # Between waves - can recruit/upgrade
    WAVE_ACTIVE,  # Fighting
    GAME_OVER
}

var game_state = GameState.PREPARATION

func _ready():
    # Spawn base
    base = base_scene.instantiate()
    add_child(base)
    base.connect("base_destroyed", Callable(self, "_on_base_destroyed"))
    
    # Start with 1 unit
    unit_manager.spawn_starting_unit()
    
    # Show recruitment panel FIRST time
    show_recruitment_panel()

func start_wave():
    game_state = GameState.WAVE_ACTIVE
    wave_in_progress = true
    emit_signal("wave_started", current_wave)
    spawn_wave_enemies(current_wave)
    
    # Hide recruitment/shop during wave
    hide_all_panels()

func on_wave_complete():
    wave_in_progress = false
    current_wave += 1
    game_state = GameState.PREPARATION
    
    # Grant rewards
    wave_rewards.complete_wave(current_wave - 1)
    
    # Show recruitment panel (player can add more units)
    show_recruitment_panel()
    
    # Auto-heal units slightly
    heal_all_units(0.2)  # 20% HP

func _on_base_destroyed():
    game_state = GameState.GAME_OVER
    show_game_over_screen()
    save_run_stats()
```

---

### 7. Prestige/Meta-Progression System (NEW)

```gdscript
# prestige_system.gd (NEW)
extends Node
class_name PrestigeSystem

# Permanent upgrades (persist across runs)
@export var prestige_currency: int = 0  # "Medals of Honor"

@export var upgrades = {
    "base_health": {
        "level": 0,
        "base_bonus": 0.1,  # +10% base HP per level
        "cost_curve": 5     # Cost: 5, 10, 15, 20...
    },
    "starting_gold": {
        "level": 0,
        "base_bonus": 50,   # +50 starting gold per level
        "cost_curve": 3
    },
    "recruitment_slot": {
        "level": 0,
        "base_bonus": 1,    # +1 max unit per level
        "cost_curve": 10
    },
    "xp_boost": {
        "level": 0,
        "base_bonus": 0.05, # +5% XP gain per level
        "cost_curve": 7
    }
}

func prestige():
    """
    Reset current run, gain prestige currency based on progress
    Called when player dies or chooses to restart
    """
    var medals_earned = calculate_medals(wave_manager.current_wave)
    prestige_currency += medals_earned
    
    # Reset run
    reset_run()
    
    # Apply permanent upgrades
    apply_prestige_upgrades()

func calculate_medals(wave_reached: int) -> int:
    """Earn 1 medal per 10 waves reached"""
    return int(wave_reached / 10)

func purchase_upgrade(upgrade_name: String):
    var upgrade = upgrades[upgrade_name]
    var cost = upgrade.level * upgrade.cost_curve
    
    if prestige_currency >= cost:
        prestige_currency -= cost
        upgrade.level += 1
        apply_upgrade_effect(upgrade_name, upgrade)
```

**Prestige Shop UI:**
```
┌──────────────────────────────────────┐
│  HALL OF HONORS (Prestige Shop)      │
│  Medals: [15]                        │
├──────────────────────────────────────┤
│ ┌────────────────────────────────┐   │
│ │ Base Health III                │   │
│ │ +30% Base HP                   │   │
│ │ Cost: 15 medals [UPGRADE]      │   │
│ └────────────────────────────────┘   │
│ ┌────────────────────────────────┐   │
│ │ Recruitment Slot II            │   │
│ │ +2 Max Units                   │   │
│ │ Cost: 20 medals [UPGRADE]      │   │
│ └────────────────────────────────┘   │
│ ┌────────────────────────────────┐   │
│ │ Starting Gold V                │   │
│ │ +250 Starting Gold             │   │
│ │ Cost: 15 medals [UPGRADE]      │   │
│ └────────────────────────────────┘   │
└──────────────────────────────────────┘
```

---

## 📊 Complete Gameplay Loop

```
┌─────────────────────────────────────────────────────────┐
│                    GAME LOOP                            │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  START RUN            │
              │  - 1 basic unit       │
              │  - Base HP: 1000      │
              │  - Gold: 100          │
              └───────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  WAVE PREPARATION     │◄───────┐
              │  - Recruit units      │        │
              │  - Buy items          │        │
              │  - Repair base        │        │
              └───────────────────────┘        │
                          │                    │
                          ▼                    │
              ┌───────────────────────┐        │
              │  WAVE BATTLE          │        │
              │  - Defend base        │        │
              │  - Units auto-fight   │        │
              │  - Abilities unlock   │        │
              └───────────────────────┘        │
                          │                    │
                          ▼                    │
              ┌───────────────────────┐        │
              │  WAVE COMPLETE?       │───NO───┤
              └───────────────────────┘        │
                          │ YES                │
                          ▼                    │
              ┌───────────────────────┐        │
              │  REWARDS              │        │
              │  - Gold               │        │
              │  - Recruitment tokens │        │
              │  - XP for units       │        │
              └───────────────────────┘        │
                          │                    │
                          ▼                    │
              ┌───────────────────────┐        │
              │  BASE DESTROYED?      │───YES──┤ (Game Over → Prestige)
              └───────────────────────┘        │
                          │ NO                 │
                          ▼                    │
              ┌───────────────────────┐        │
              │  NEXT WAVE            │────────┘
              │  (wave_number++)      │
              └───────────────────────┘
```

---

## 🎨 UI/UX Changes Required

### New UI Elements

| Element | Purpose | Location |
|---------|---------|----------|
| Base Health Bar | Show base HP | Top center, prominent |
| Recruitment Panel | Recruit new units | Right side (between waves) |
| Ability Unlock Popup | Notify skill unlocks | Center screen popup |
| Wave Counter | Current wave | Top left |
| Unit Count | X/Y units | Top left (near wave) |
| Prestige Shop | Permanent upgrades | Main menu |
| Unit Level Indicators | Show unit levels | Above each unit |

### Modified UI Elements

| Element | Change |
|---------|--------|
| Shop | Only appears BETWEEN waves now |
| Currency Display | Add recruitment token counter |
| Health bars | Add base HP bar (not just units) |

---

## 📝 Implementation Checklist

### Phase 1: Core Systems
- [ ] Create `base.gd` with health/defense
- [ ] Add base health bar to UI
- [ ] Modify `main_game.gd` game state machine
- [ ] Change win condition: Base survives = win wave
- [ ] Update `wave_manager.gd` for infinite scaling

### Phase 2: Unit Management
- [ ] Create `unit_manager.gd` (single unit start)
- [ ] Implement recruitment token system
- [ ] Create recruitment panel UI
- [ ] Add recruitment slot upgrades

### Phase 3: Ability Progression
- [ ] Create `ability_unlock.gd` system
- [ ] Modify all unit classes to start without skills
- [ ] Add level-based unlock triggers (3, 7, 15)
- [ ] Create unlock notification popups

### Phase 4: Prestige System
- [ ] Create `prestige_system.gd`
- [ ] Add prestige currency (Medals)
- [ ] Create prestige shop UI
- [ ] Implement permanent upgrades
- [ ] Add "Prestige" button on game over

### Phase 5: Balance & Polish
- [ ] Tune wave difficulty curve
- [ ] Balance recruitment token rewards
- [ ] Test unit power progression
- [ ] Add visual feedback for base damage
- [ ] Create tutorial for new players

---

## 🎮 Inspiration from Successful Incremental Games

### 1. **They Are Billions** (Base Defense)
- Start with 1 unit
- Expand slowly
- Defend central base
- **Adapt**: Recruitment tokens limit expansion pace

### 2. **Idle Defense Games** (Mobile genre)
- Auto-battle
- Upgrade between waves
- Exponential number growth
- **Adapt**: Keep manual elements but automate combat

### 3. **Slay the Spire** (Progression)
- Unlock abilities through gameplay
- Feel stronger each run
- **Adapt**: Level-based ability unlocks

### 4. **Loop Hero** (Meta-progression)
- Prestige currency
- Permanent upgrades
- **Adapt**: Medals of Honor system

### 5. **Melvor Idle** (Skill unlocks)
- Skills unlock at milestones
- Creates progression feeling
- **Adapt**: Level 3/7/15 ability gates

---

## 📈 Difficulty Curve Design

### Early Game (Waves 1-10)
- **Goal**: Teach mechanics, feel progression
- **Enemies**: Goblins only (3 → 8 per wave)
- **HP Scaling**: ×1.3 per wave
- **Unlocks**: First ability at wave 3

### Mid Game (Waves 11-50)
- **Goal**: Strategic decisions, unit composition
- **Enemies**: Mixed types (brutes, shamans)
- **HP Scaling**: ×1.5 per wave
- **Unlocks**: Ultimate abilities at wave 15+

### Late Game (Waves 51-100)
- **Goal**: Test build, push limits
- **Enemies**: Elite variants
- **HP Scaling**: ×1.7 per wave
- **Challenge**: Base health management critical

### Endless (Waves 101+)
- **Goal**: Prestige farming, leaderboards
- **Enemies**: Boss variants
- **HP Scaling**: ×2.0 per wave
- **Inevitable**: Will lose, gain medals for next run

---

## 💡 Key Design Principles

### 1. **Meaningful Scarcity**
- ❌ Don't give all units at start
- ✅ Force choices: "Which unit to recruit first?"

### 2. **Progression Visibility**
- ❌ Don't hide power growth
- ✅ Show numbers going up (level popups, damage numbers)

### 3. **Loss = Progress**
- ❌ Don't make death feel bad
- ✅ Death = Medals = Permanent upgrades

### 4. **Simple Core, Deep Systems**
- ❌ Don't overcomplicate combat
- ✅ Auto-battle + strategic recruitment/upgrades

### 5. **Session Flexibility**
- ❌ Don't require long sessions
- ✅ Can prestige after 10 waves OR push to 100+

---

## 🔧 Technical Migration Notes

### Files to Create (NEW)
```
Scripts/
├── base.gd
├── unit_manager.gd
├── ability_unlock.gd
├── prestige_system.gd
├── recruitment_panel.gd
└── wave_rewards.gd

Scenes/
├── base.tscn
├── recruitment_panel.tscn
└── prestige_shop.tscn
```

### Files to Modify
```
main_game.gd        → Complete overhaul
wave_manager.gd     → Infinite scaling
character.gd        → Remove starting skills
knight.gd, etc.     → Remove learned_skills initialization
shop.gd            → Only accessible between waves
global.gd          → Add prestige currency
```

### Backwards Compatibility
- Keep existing skill system (just gate it)
- Keep existing item system (works as-is)
- Keep existing enemy types (add scaling)
- Keep existing unit classes (modify _ready())

---

## 🎯 Success Metrics

After transformation, the game should:

1. ✅ **Start Small**: Player has exactly 1 unit with NO skills at wave 1
2. ✅ **Feel Growth**: Units unlock abilities at levels 3, 7, 15
3. ✅ **Meaningful Choices**: Recruitment tokens force strategic decisions
4. ✅ **Base Focus**: Base health is the primary failure condition
5. ✅ **Endless Potential**: Wave 100+ is achievable with good builds
6. ✅ **Prestige Loop**: Death feels like progress (medals earned)
7. ✅ **Session Flexibility**: Can play 10 min or 2 hour sessions

---

## 📚 Additional Resources

### Recommended Reading
- "Incremental Game Design" by Anthony Pecorella (Cookie Clicker dev)
- GDC Talk: "The Math Behind Idle Games"
- r/incremental_games (Reddit community)

### Tools
- **Desmos**: For balancing exponential curves
- **Google Sheets**: Wave difficulty spreadsheet
- **Godot Plugins**: Consider "Auto Save" for prestige persistence

---

**Document Version**: 1.0  
**Created**: March 2026  
**For**: 3 Heroes Stand → Base Defense Incremental Transformation
