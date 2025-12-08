# Game Design Document: 3 Heroes - Roguelike Autobattler

## 1. Game Overview
**Genre**: Roguelike Autobattler
**Platform**: PC (Godot Engine 4.x)
**Core Loop**:
1.  **Skill Selection Phase**: After each wave, players choose 1 skill per hero to build their strategy.
2.  **Combat Phase**: Wave of enemies spawns. Heroes fight automatically.
3.  **Progression**: Skills unlock in tiers based on wave progress (Tier 1 → Tier 2 → Tier 3).

## 2. Characters & Classes
| Class | Role | Key Stats |
|-------|------|-----------|
| **Valkyrie** | Melee DPS | High attack, medium defense |
| **Cleric** | Healer/Support | Healing skills, buffs |
| **Wizard** | Ranged Mage | High damage, low health |

### Stat System
- **Health/Max Health**: HP points
- **Attack Damage**: Damage per hit
- **Defense**: Damage reduction
- **Attack Cooldown**: Time between attacks
- **Move Speed**: Movement velocity
- **Attack Range**: Distance to attack from

## 3. Core Systems

### 3.1 Combat (Auto-Battle)
- Heroes automatically target nearest enemy
- Attack when in range, move closer otherwise
- Status effects: Stun, Slow, Invincibility

### 3.2 Skill Progression
| Waves | Skill Tier | Skill Types |
|-------|------------|-------------|
| 1-3 | Tier 1 | Basic abilities |
| 4-6 | Tier 2 | Powerful abilities |
| 7-10 | Tier 3 | Ultimate abilities |

**Skill Types**:
- **Active**: Auto-cast on cooldown (Fireball, Heal, etc.)
- **Passive**: Permanent stat bonuses (Weapon Mastery, Defense Mastery)

### 3.3 Wave System
- 10 waves total
- Difficulty scales with wave number
- Wave 10 = Boss wave (King Goblin)

## 4. Win/Lose Conditions
- **Victory**: Clear all 10 waves
- **Game Over**: All 3 heroes die

## 5. Enemy Types
| Enemy | Behavior |
|-------|----------|
| Goblin | Basic melee |
| Goblin Brute | Tanky melee |
| Goblin Shaman | Ranged magic |
| Goblin Berserker | High DPS |
| Goblin Assassin | Fast, deadly |
| King Goblin | Wave 10 Boss |

## 6. Future Improvements
- [ ] Add more hero classes (Knight, Archer)
- [ ] Item/equipment drops
- [ ] Shop between waves
- [ ] Visual skill effects
- [ ] Sound effects & music
- [ ] Meta-progression (run unlocks)


