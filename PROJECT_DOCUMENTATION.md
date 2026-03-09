# 3 Heroes - Project Documentation

## Game Overview

**3 Heroes** is a **Roguelike Autobattler** built with Godot Engine 4.x. Players control a party of three heroes who automatically battle through waves of enemies, strategically selecting skills after each wave to build powerful synergies.

---

## Table of Contents

1. [Core Gameplay](#core-gameplay)
2. [Playable Characters](#playable-characters)
3. [Enemy Types](#enemy-types)
4. [Wave System](#wave-system)
5. [Skill System](#skill-system)
6. [Combat Mechanics](#combat-mechanics)
7. [Progression Systems](#progression-systems)
8. [UI & Interface](#ui--interface)
9. [Project Structure](#project-structure)
10. [Technical Implementation](#technical-implementation)

---

## Core Gameplay

### Game Loop
1. **Skill Selection Phase** - After each wave, players choose 1 skill per hero
2. **Combat Phase** - Heroes automatically fight waves of enemies
3. **Progression** - Skills unlock in tiers based on wave progress
4. **Victory/Defeat** - Clear all 10 waves or all heroes die

### Win/Lose Conditions
- **Victory**: Defeat all 10 waves including the King Goblin boss
- **Game Over**: All 3 heroes fall in battle

---

## Playable Characters

### 1. Cleric (Healer/Support)
| Stat | Value |
|------|-------|
| Max Health | 500 |
| Role | Healing & Support |
| Attack Range | Melee |

**Special Abilities:**
- Automatically finds and heals injured allies
- Healing cooldown: 2.0 seconds
- Base heal amount: 40 HP

**Skill Tiers:**
- **Tier 1 (Waves 1-3)**: Purifying Wave, Healing Light, Divine Shield
- **Tier 2 (Waves 4-6)**: Holy Hands, Radiant Aura, Mass Heal
- **Tier 3 (Waves 7+)**: Defense Mastery, Healing Mastery, Crescendo

---

### 2. Valkyrie (Melee DPS)
| Stat | Value |
|------|-------|
| Max Health | 350 |
| Attack Damage | 70 |
| Defense | 8 |
| Move Speed | 85 |
| Attack Cooldown | 1.2s |

**Special Abilities:**
- High mobility melee fighter
- Fast attack speed
- Norse mythology-themed skills

**Skill Tiers:**
- **Tier 1 (Waves 1-3)**: Spear Throw, Valhalla's Call, Thunder Strike
- **Tier 2 (Waves 4-6)**: Fenrir's Wrath, Ragnarök, Valkyrie's Zeal
- **Tier 3 (Waves 7+)**: Crescendo, Weapon Mastery, Defense Mastery

---

### 3. Wizard (Ranged Mage)
| Stat | Value |
|------|-------|
| Max Health | 200 |
| Attack Damage | 62 |
| Defense | 5 |
| Move Speed | 50 |
| Attack Range | 300.0 |
| Attack Cooldown | 2.0s |

**Special Abilities:**
- Long-range projectile attacks (Magic Bolts)
- High damage, low health
- Area-of-effect spells

**Skill Tiers:**
- **Tier 1 (Waves 1-3)**: Fireball, Ice Nova, Black Hole
- **Tier 2 (Waves 4-6)**: Meteor Strike, Arcane Shield, Haste
- **Tier 3 (Waves 7+)**: Chain Lightning, Haste, Weapon Mastery

---

## Enemy Types

### Basic Enemies
| Enemy | Role | Behavior |
|-------|------|----------|
| **Goblin** | Basic Melee | Standard enemy, balanced stats |
| **Goblin Brute** | Tank | High health, slow movement |
| **Goblin Shaman** | Ranged | Magic attacks from distance |
| **Goblin Berserker** | High DPS | Fast, deadly melee attacker |
| **Goblin Assassin** | Speed/Burst | Fast movement, high damage |

### Boss
| Enemy | Wave | Behavior |
|-------|------|----------|
| **King Goblin** | 10 | Final boss, massive stats |

### Enemy Mechanics
- **Knockback**: Enemies can be knocked back by certain skills
- **Slow**: Movement speed reduction (50% for duration)
- **Stun**: Completely immobilizes enemy
- **Taunt**: Forces enemies to attack specific target

---

## Wave System

### Wave Configuration
| Wave | Enemies |
|------|---------|
| 1 | 3x Goblin |
| 2 | 5x Goblin, 1x Goblin Brute |
| 3 | 4x Goblin, 2x Goblin Shaman |
| 4 | 2x Goblin Brute, 2x Goblin Shaman |
| 5 | 3x Goblin Berserker, 4x Goblin |
| 6 | 3x Goblin Shaman, 3x Goblin Brute |
| 7 | 3x Goblin Assassin, 2x Goblin |
| 8 | 2x Goblin Shaman, 3x Goblin Assassin |
| 9 | 4x Goblin Berserker |
| 10 | 1x King Goblin (Boss) |

### Wave Flow
1. Wave timer counts down between waves (1.5s)
2. Enemies spawn in designated area (500-750, 50-350 coordinates)
3. All enemies must be defeated to progress
4. Skill selection phase triggers after each wave
5. Initial skill selection occurs before Wave 1

---

## Skill System

### Skill Types

#### Active Skills
- Auto-cast on cooldown
- Require target selection or area effect
- Examples: Fireball, Heal, Shield Bash

#### Passive Skills
- Permanent stat bonuses
- Always active once learned
- Examples: Weapon Mastery (+10 ATK), Defense Mastery (+20 DEF), Crescendo (+50 HP)

### Skill Selection Rules
- **3 skills offered** per character each wave
- **1 skill must be selected** per character (flexible for faster gameplay)
- **Skill tier** based on wave progress:
  - Waves 1-3: Tier 1 skills (level 3)
  - Waves 4-6: Tier 2 skills (level 6)
  - Waves 7+: Tier 3 skills (level 9)

### Notable Skills

#### Cleric Skills
| Skill | Cooldown | Effect |
|-------|----------|--------|
| Healing Light | 10s | Heal ally for 20% max HP |
| Mass Heal | 30s | Heal all allies by 20% max HP |
| Divine Shield | 10s | Make ally invincible for 3s |
| Radiant Aura | 15s | Regenerate HP of all allies for 5s |
| Purifying Wave | 15s | Heal all allies and remove debuffs |

#### Valkyrie Skills
| Skill | Cooldown | Effect |
|-------|----------|--------|
| Spear Throw | 3s | Throw spear at farthest enemy |
| Thunder Strike | 8s | Deal lightning damage to random enemy |
| Ragnarök | 20s | Deal massive damage to all enemies |
| Valhalla's Call | 10s | Below 20% HP: reduce cooldown, increase speed, lifesteal |
| Fenrir's Wrath | Passive | 25% chance to deal 120% attack damage |

#### Wizard Skills
| Skill | Cooldown | Effect |
|-------|----------|--------|
| Fireball | 5s | Deal 80 damage to nearest enemy |
| Ice Nova | 8s | Damage + slow enemies in area |
| Meteor Strike | 10s | Area damage to all enemies |
| Chain Lightning | 10s | Jump to 3 enemies with reduced damage |
| Black Hole | 12s | Pull enemies in, deal continuous damage |
| Arcane Shield | 12s | Absorb damage for short duration |

---

## Combat Mechanics

### Auto-Battle System
- Heroes automatically target nearest enemy
- Move into range if target is too far
- Attack when in range, otherwise move
- Skills auto-cast when available

### Targeting System
```gdscript
func find_nearest_target(group_name: String) -> Node2D:
    # Finds nearest node in specified group
    # Used for both heroes and enemies
```

### Damage Calculation
```gdscript
reduced_damage = max(damage - defense, 0)
```

### Status Effects

| Effect | Duration | Impact |
|--------|----------|--------|
| **Stun** | Variable | Cannot move or attack |
| **Slow** | Variable | 50% movement speed reduction |
| **Invincibility** | Variable | Take no damage |
| **Shield Block** | Until broken | Block X attacks |
| **Taunt** | 5s | Enemies forced to attack taunter |
| **Lifesteal** | Instant | Heal for % of damage dealt |

### Special Mechanics

#### Lifesteal
- Percentage of damage dealt converts to healing
- Formula: `heal_amount = damage_dealt * lifesteal_percentage`

#### Shield Systems
- **Arcane Shield**: Absorbs damage for duration
- **Big Shield**: Blocks specific number of attacks
- **Divine Shield**: Complete invincibility

#### Knockback
- Applied as velocity force
- Gradually reduced by friction (200 reduction rate)
- Can interrupt enemy positioning

---

## Progression Systems

### Level System
- Heroes gain XP from defeating enemies
- XP rewards: 100 XP per enemy kill
- Level-up requirements double each level (×2.5)
- Stats increase on level up:
  - Health: +20 per level
  - Damage: +5 per level
  - Defense: +2 per level

### Economy System
- **Gold/Currency**: Earned from defeating enemies
- Random gold drops: 10-20 gold per enemy
- Shared party currency (global system)
- Starting gold: 100

### Stat Growth

#### Base Stats by Character
| Stat | Cleric | Valkyrie | Wizard |
|------|--------|----------|--------|
| Health | 500 | 350 | 200 |
| Damage | 10 | 70 | 62 |
| Defense | 5 | 8 | 5 |
| Speed | 80 | 85 | 50 |
| Range | 80 | 80 | 300 |

#### Growth Rates
- **Health Growth**: +20 per level
- **Damage Growth**: +5 per level
- **Defense Growth**: +2 per level

---

## UI & Interface

### Main UI Elements

#### Character Selection Panel
- Buttons for Cleric, Valkyrie, Wizard
- Switch active character for inventory/stats view
- Shows current active character name

#### Skill Selection Panel
- Displays 3 skill options per hero
- Shows skill icons and descriptions (tooltips)
- Confirm button to resume game
- Appears after each wave

#### Stats Display
- Shows active character's current stats
- Updates in real-time
- Includes: HP, Damage, Defense, Speed, etc.

#### Wave Label
- Displays current wave number
- Shows "Choose Skills!" during selection
- Shows "GAME OVER" or "VICTORY" on end states

#### Health Bars
- Individual HP display per character
- Floating damage/healing numbers
- Color-coded (red for damage, green for healing)

---

## Project Structure

```
3_heroes/
├── Assets/                    # Art, icons, sounds
├── Enemies/                   # Enemy scripts and scenes
│   ├── enemy.gd
│   ├── goblin.tscn
│   ├── goblin_brute.gd
│   ├── goblin_shaman.gd
│   ├── goblin_berserker.gd
│   ├── goblin_assassin.gd
│   └── king_goblin.gd
├── Skills/                    # Skill implementations
│   ├── Wizard/               # Wizard-specific skills
│   ├── Cleric/               # Cleric-specific skills
│   ├── Valkyrie/             # Valkyrie-specific skills
│   └── *.gd                  # Individual skill scripts
├── base_character.gd         # Base character class
├── cleric.gd                 # Cleric character class
├── valkyrie.gd               # Valkyrie character class
├── wizard.gd                 # Wizard character class
├── skill.gd                  # Skill resource class
├── SkillDatabase.gd          # Skill database & distribution
├── main_game.gd              # Main game controller
├── wave_manager.gd           # Wave configuration
├── ui.gd                     # UI controller
├── level_system.gd           # XP and leveling
├── global.gd                 # Global state (currency)
├── Constants.gd              # Game constants & enums
├── magic_bolt.gd             # Wizard projectile
└── interaction.gd            # Interaction system
```

### Key Scene Files
- `Game.tscn` - Main game scene
- `main_game.tscn` - Game controller scene
- `ui.tscn` - User interface
- `base_character.tscn` - Base character template
- `cleric.tscn`, `valkyrie.tscn`, `wizard.tscn` - Hero scenes
- `statsdisplay.tscn` - Stats panel
- `tooltip.tscn` - Tooltip UI

---

## Technical Implementation

### Architecture

#### Inheritance Hierarchy
```
CharacterBody2D
└── BaseCharacter (base_character.gd)
    ├── Cleric (cleric.gd)
    ├── Valkyrie (valkyrie.gd)
    ├── Wizard (wizard.gd)
    └── Enemy (enemy.gd)
        ├── Goblin
        ├── GoblinBrute
        ├── GoblinShaman
        ├── GoblinBerserker
        ├── GoblinAssassin
        └── KingGoblin
```

#### Key Systems

##### 1. Base Character System (`base_character.gd`)
- Health management
- Attack logic with target finding
- Damage calculation with defense
- Status effects (stun, invincibility, shield)
- Level-up integration
- Skill learning system
- Lifesteal mechanics

##### 2. Skill System (`skill.gd`)
- Resource-based skill definitions
- Active vs Passive classification
- Cooldown management
- Effect application
- Stat bonuses (attack, defense, health)

##### 3. Wave Manager (`wave_manager.gd`)
- Wave configuration dictionary
- Enemy spawning logic
- Wave progression tracking

##### 4. Main Game Controller (`main_game.gd`)
- Wave state management
- Win/lose condition checking
- Skill selection triggering
- Game pause/resume

##### 5. UI Controller (`ui.gd`)
- Character switching
- Skill button setup
- Stats display updates
- Inventory integration

### Signal System

#### Main Signals
```gdscript
# main_game.gd
signal wave_skill_popup    # Trigger skill selection
signal game_over           # Game over state
signal victory             # Victory state

# level_system.gd
signal leveled_up          # Character level up

# ui.gd
signal character_switched  # Active character changed
```

### Groups
- **PlayerCharacters**: All hero instances
- **Enemies**: All enemy instances

### Timers & Cooldowns
- Attack timers (per character)
- Skill cooldown timers (dictionary-based)
- Status effect timers (stun, slow, taunt, invincibility)
- Wave timer (between waves)

### Save System
- Uses UID system for Godot 4.4+ compatibility
- Resource-based skill storage
- Scene references for instantation

---

## Development Tools

### Godot MCP Integration
Project includes Godot MCP configuration for AI-assisted development:
- `.cursor/mcp.json` - Cursor IDE configuration
- `claude_desktop_config.json` - Claude Desktop configuration
- `cline_mcp_settings.json` - Cline VS Code extension

### Available MCP Tools
- Launch Godot Editor
- Run/Stop projects
- Capture debug output
- Create scenes
- Add nodes
- Export mesh libraries
- Manage UIDs (Godot 4.4+)

---

## Future Improvements (from GDD)

- [ ] Add more hero classes (Knight, Archer)
- [ ] Item/equipment drops
- [ ] Shop between waves
- [ ] Visual skill effects
- [ ] Sound effects & music
- [ ] Meta-progression (run unlocks)
- [ ] Balance adjustments
- [ ] More enemy varieties
- [ ] Achievement system
- [ ] Difficulty modes

---

## Credits & Technologies

- **Engine**: Godot Engine 4.x
- **Language**: GDScript
- **MCP Tool**: godot-mcp (Coding-Solo)
- **Genre**: Roguelike Autobattler
- **Platform**: PC

---

*Last Updated: March 2026*
