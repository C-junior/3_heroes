# Game Design Document: 3 Heroes
## Roguelike Auto-Battler Survivor

**Version**: 2.0  
**Last Updated**: March 2026  
**Engine**: Godot 4.x  
**Platform**: PC (Steam/Itch.io)  
**Target Session Length**: 15-25 minutes per run  

---

## 1. Executive Summary

### 1.1 Game Concept
**3 Heroes** is a **fast-paced roguelike auto-battler** where players control a party of 3 heroes fighting through endless waves of enemies. After each wave, players choose powerful skills to build unique synergies. The game combines the addictive progression of *Vampire Survivors* with the strategic team-building of *Teamfight Tactics*.

### 1.2 Core Fantasy
> *"You are the last commander of three legendary heroes, fighting against an endless goblin horde. With each battle, your heroes grow stronger, unlocking devastating combinations of abilities. Can you survive all 10 waves and defeat the Goblin King?"*

### 1.3 Design Pillars
| Pillar | Description |
|--------|-------------|
| **Simple Controls** | Point, click, and watch your heroes dominate |
| **Build Diversity** | Every run feels different with 60+ skills |
| **Fast Progression** | Power fantasy ramps up quickly |
| **Meaningful Choices** | Each skill pick matters |
| **Satisfying Feedback** | Big numbers, screen shake, visual chaos |

### 1.4 Comparable Games & Lessons

| Game | What We're Borrowing | Adaptation |
|------|---------------------|------------|
| **Vampire Survivors** | Exponential power growth, passive abilities | Auto-battler combat + active skill choices |
| **Brotato** | Simple stats, weapon variety | 3 heroes instead of 1, more synergies |
| **Teamfight Tactics** | Team composition strategy | Real-time combat, faster rounds |
| **Risk of Rain** | Scaling difficulty, item synergies | Wave-based instead of time-based |
| **Loop Hero** | Auto-combat with strategic decisions | Direct hero control between waves |

---

## 2. Gameplay Loop

### 2.1 The Core Loop (15-25 minutes)

```
┌─────────────────────────────────────────────────────────┐
│                    WAVE PREPARATION                      │
│  • Choose 1 skill per hero (3 total)                    │
│  • Review enemy types for next wave                     │
│  • Plan build synergies                                 │
│  Duration: 30-60 seconds                                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                      COMBAT PHASE                        │
│  • Heroes auto-fight enemies                            │
│  • Skills activate automatically                        │
│  • Watch your build in action                           │
│  Duration: 1-3 minutes per wave                         │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    REWARD PHASE                          │
│  • Gain gold from kills                                 │
│  • Gain XP and level up                                 │
│  • Stats increase automatically                         │
│  Duration: Instant                                      │
└─────────────────────────────────────────────────────────┘
                          ↓
                    [Repeat x10]
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    FINAL BOSS                            │
│  • Wave 10: King Goblin                                 │
│  • Victory or Game Over                                 │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Player Actions Per Wave

| Phase | Player Input | Frequency |
|-------|-------------|-----------|
| Skill Selection | Click 3 buttons (1 per hero) | Once per wave |
| Combat | None (watch only) | Automatic |
| Between Waves | Confirm choices | Once per wave |

**Design Goal**: Minimal APM (Actions Per Minute), maximum strategic depth.

---

## 3. Characters & Classes

### 3.1 Hero Roster

The game launches with **3 distinct heroes**, each with unique playstyles and skill pools.

| Hero | Role | Health | Damage | Speed | Range | Complexity |
|------|------|--------|--------|-------|-------|------------|
| **Cleric** | Healer/Support | ★★★★★ | ★★☆ | ★★★ | ★★☆ | Easy |
| **Valkyrie** | Melee DPS | ★★★★☆ | ★★★★☆ | ★★★★☆ | ★★☆ | Medium |
| **Wizard** | Ranged Mage | ★★☆☆☆ | ★★★★★ | ★★☆☆☆ | ★★★★★ | Hard |

### 3.2 Character Details

#### **Cleric** - The Immortal Support
*"Never let your allies fall."*

**Base Stats:**
- Health: 500 (highest)
- Damage: 10 (lowest)
- Defense: 5
- Speed: 80
- Range: 80 (melee)

**Unique Mechanic**: Automatically heals lowest HP ally when in range

**Playstyle**: 
- Position behind tanks
- Keep everyone alive
- Build healing power or tankiness

**Ideal For**: Beginners, defensive players

---

#### **Valkyrie** - The Balanced Fighter
*"Glory awaits in Valhalla!"*

**Base Stats:**
- Health: 350 (balanced)
- Damage: 70 (high)
- Defense: 8 (highest)
- Speed: 85 (fastest)
- Range: 80 (melee)

**Unique Mechanic**: Lifesteal on low health (Valhalla's Call)

**Playstyle**:
- Front-line fighter
- Sustained damage dealer
- Build attack speed or crit

**Ideal For**: Aggressive players, balanced builds

---

#### **Wizard** - The Glass Cannon
*"Power comes at a price."*

**Base Stats:**
- Health: 200 (lowest)
- Damage: 62 (very high)
- Defense: 5
- Speed: 50 (slowest)
- Range: 300 (longest)

**Unique Mechanic**: Projectile-based attacks (Magic Bolts)

**Playstyle**:
- Stay at maximum range
- Burst damage dealer
- Build cooldown reduction or AoE

**Ideal For**: Experienced players, positioning-focused

---

## 4. Skill System

### 4.1 Skill Distribution

**Total Skills**: 60+ (20 per character tier)

| Tier | Waves | Skills per Hero | Total Available |
|------|-------|-----------------|-----------------|
| Tier 1 | 1-3 | 9 skills | 27 skills |
| Tier 2 | 4-6 | 9 skills | 27 skills |
| Tier 3 | 7-10 | 9 skills | 27 skills |

### 4.2 Skill Types

#### **Active Skills** (60%)
- Auto-cast on cooldown
- Have visual effects
- Examples: Fireball, Heal, Shield Bash

#### **Passive Skills** (40%)
- Always active
- Stat bonuses or special effects
- Examples: Weapon Mastery, Lifesteal, Cooldown Reduction

### 4.3 Skill Rarity System

| Rarity | Color | Effect Strength | Drop Rate |
|--------|-------|-----------------|-----------|
| **Common** | White | Base values | 50% |
| **Rare** | Blue | +50% values | 35% |
| **Epic** | Purple | +100% values | 15% |

*Future expansion: Add rarity to skill selection*

### 4.4 Signature Skills (Examples)

#### Cleric Signature Skills
| Skill | Tier | Type | Cooldown | Effect |
|-------|------|------|----------|--------|
| **Healing Light** | 1 | Active | 10s | Heal ally for 20% max HP |
| **Divine Shield** | 1 | Active | 10s | Ally invincible for 3s |
| **Mass Heal** | 2 | Active | 30s | Heal all allies 20% max HP |
| **Radiant Aura** | 2 | Active | 15s | HoT on all allies for 5s |
| **Resurrection** | 3 | Active | 60s | Revive fallen ally with 50% HP |
| **Healing Mastery** | 3 | Passive | — | +50% healing power |

#### Valkyrie Signature Skills
| Skill | Tier | Type | Cooldown | Effect |
|-------|------|------|----------|--------|
| **Spear Throw** | 1 | Active | 3s | Ranged spear attack |
| **Thunder Strike** | 1 | Active | 8s | Lightning damage to random enemy |
| **Ragnarök** | 2 | Active | 20s | AoE damage to all enemies |
| **Valhalla's Call** | 1 | Passive | — | Lifesteal when <20% HP |
| **Fenrir's Wrath** | 2 | Passive | — | 25% chance for 120% damage |
| **Berserker Mode** | 3 | Passive | — | +100% ATK, -50% DEF |

#### Wizard Signature Skills
| Skill | Tier | Type | Cooldown | Effect |
|-------|------|------|----------|--------|
| **Fireball** | 1 | Active | 5s | 80 damage to nearest enemy |
| **Ice Nova** | 1 | Active | 8s | AoE damage + slow |
| **Black Hole** | 1 | Active | 12s | Pull enemies, DoT |
| **Meteor Strike** | 2 | Active | 10s | Massive AoE damage |
| **Chain Lightning** | 3 | Active | 10s | Bounces to 3 enemies |
| **Arcane Mastery** | 3 | Passive | — | -30% cooldown, +50% mana |

### 4.5 Build Archetypes

Players can pursue these synergistic builds:

| Build Name | Core Idea | Key Skills | Heroes |
|------------|-----------|------------|--------|
| **Immortal Party** | Maximum healing + tankiness | Healing Mastery, Divine Shield, Defense Mastery | Cleric-focused |
| **Glass Cannon** | Maximum damage, ignore defense | Weapon Mastery, Berserker, Cooldown Reduction | Wizard + Valkyrie |
| **Speed Demon** | Attack speed + movement speed | Haste, Valkyrie's Zeal, Lightning | All heroes |
| **AoE Nuke** | Area damage everywhere | Ragnarök, Meteor, Chain Lightning | Wizard + Valkyrie |
| **Lifesteal Army** | Sustain through damage | Lifesteal, Fenrir's Wrath, Healing | Valkyrie-focused |

---

## 5. Enemy Design

### 5.1 Enemy Philosophy

Enemies should be **simple to understand** but **challenging in numbers**. Inspired by *Vampire Survivors*, the satisfaction comes from watching your build obliterate hordes.

### 5.2 Enemy Roster

#### **Basic Enemies** (Waves 1-5)

| Enemy | Health | Damage | Speed | Special | Wave Debut |
|-------|--------|--------|-------|---------|------------|
| **Goblin** | 100 | 28 | 40 | None | Wave 1 |
| **Goblin Brute** | 300 | 35 | 30 | Tanky | Wave 2 |
| **Goblin Shaman** | 80 | 45 | 35 | Ranged attack | Wave 3 |

#### **Advanced Enemies** (Waves 4-8)

| Enemy | Health | Damage | Speed | Special | Wave Debut |
|-------|--------|--------|-------|---------|------------|
| **Goblin Berserker** | 150 | 50 | 60 | Fast attacks | Wave 5 |
| **Goblin Assassin** | 120 | 60 | 70 | High burst | Wave 7 |

#### **Boss** (Wave 10)

| Enemy | Health | Damage | Speed | Special |
|-------|--------|--------|-------|---------|
| **King Goblin** | 5000 | 80 | 35 | Summons minions, AoE slam |

### 5.3 Enemy Scaling

Enemies scale with wave number:

```
Wave 1: 100% base stats
Wave 2: 120% base stats
Wave 3: 140% base stats
...
Wave 10: 280% base stats (boss only)
```

### 5.4 Enemy Count Per Wave

| Wave | Total Enemies | Composition |
|------|---------------|-------------|
| 1 | 3 | 3x Goblin |
| 2 | 6 | 5x Goblin, 1x Brute |
| 3 | 6 | 4x Goblin, 2x Shaman |
| 4 | 4 | 2x Brute, 2x Shaman |
| 5 | 7 | 3x Berserker, 4x Goblin |
| 6 | 6 | 3x Shaman, 3x Brute |
| 7 | 5 | 3x Assassin, 2x Goblin |
| 8 | 5 | 2x Shaman, 3x Assassin |
| 9 | 4 | 4x Berserker |
| 10 | 1 | 1x King Goblin (Boss) |

**Design Note**: Later waves have fewer but stronger enemies to prevent performance issues and make each enemy feel threatening.

---

## 6. Progression Systems

### 6.1 In-Run Progression

#### Level System
- **XP Source**: Killing enemies (100 XP per kill)
- **Level Cap**: None (infinite scaling)
- **XP Curve**: Each level requires 2.5× previous XP
- **Rewards per Level**:
  - +20 Max Health
  - +5 Attack Damage
  - +2 Defense
  - Full heal

#### Gold System
- **Source**: Enemy drops (10-20 random per kill)
- **Current Use**: Future shop system
- **Starting Gold**: 100

### 6.2 Meta-Progression (Future)

| System | Description | Unlock Condition |
|--------|-------------|------------------|
| **New Heroes** | Unlock Knight, Archer, Necromancer | Beat game with each hero |
| **Starting Bonances** | Begin with extra gold/HP | Complete challenges |
| **Skill Unlocks** | Add new skills to pools | Beat specific waves |
| **Difficulty Modes** | Hard, Nightmare, Hell | Beat game on previous |
| **Achievements** | Steam/Itch achievements | Various challenges |

---

## 7. Combat Mechanics

### 7.1 Auto-Battle Rules

**Heroes automatically:**
1. Find nearest enemy in range
2. Move toward enemy if out of range
3. Attack when in range
4. Cast skills when off cooldown

**Player has NO combat control** - this is intentional for the genre.

### 7.2 Targeting Priority

```
1. Nearest enemy (default)
2. Lowest HP enemy (assassin types)
3. Highest threat (tanks, bosses)
```

### 7.3 Damage Formula

```gdscript
# Basic damage calculation
final_damage = max(attack_damage - defense, 1)

# Critical hits (future)
if roll_crit():
    final_damage *= crit_multiplier

# Damage reduction (shields, buffs)
final_damage *= (1 - damage_reduction_percent)
```

### 7.4 Status Effects

| Effect | Duration | Visual | Impact |
|--------|----------|--------|--------|
| **Stun** | 2s | Yellow flash | Can't move/attack |
| **Slow** | 3s | Blue aura | -50% movement speed |
| **Invincible** | 3s | Golden glow | Take 0 damage |
| **Poison** | 5s | Green particles | DoT over time |
| **Burn** | 4s | Orange particles | DoT, stacks |
| **Taunt** | 5s | Red arrows | Enemies target this unit |

### 7.5 Positioning System

Heroes spawn in fixed formation:
```
                    ENEMIES →
    ┌─────────────────────────────────┐
    │                                 │
    │    [Wizard]                     │
    │    [Cleric]                     │
    │    [Valkyrie]                   │
    │                                 │
    └─────────────────────────────────┘
         Spawn: (100, 100-300)
```

**Design Note**: Fixed positioning reduces complexity and ensures consistent gameplay.

---

## 8. UI/UX Design

### 8.1 Screen Layout

```
┌─────────────────────────────────────────────────────────────┐
│  WAVE 5                                    [Pause]          │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│                                                             │
│                    [COMBAT AREA]                            │
│                                                             │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│  [Cleric] HP: ████████░░ 80%    [Active: Cleric]           │
│  [Valkyrie] HP: ██████░░░░ 60%                              │
│  [Wizard] HP: ██████████ 100%                               │
│                                                             │
│  [Gold: 450] [Level: 7] [XP: ████████░░ 80/200]            │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 Skill Selection Screen

```
┌─────────────────────────────────────────────────────────────┐
│                    CHOOSE YOUR SKILLS                        │
│                    Wave 5 Complete!                          │
│  ─────────────────────────────────────────────────────────  │
│                                                              │
│  CLERIC                          VALKYRIE                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐   ┌──────────┐     │
│  │ [Icon]   │ │ [Icon]   │ │ [Icon]   │   │ [Icon]   │     │
│  │ Heal     │ │ Shield   │ │ Purify   │   │ Spear    │     │
│  │ Tooltip  │ │ Tooltip  │ │ Tooltip  │   │ Tooltip  │     │
│  └──────────┘ └──────────┘ └──────────┘   └──────────┘     │
│                                                              │
│  WIZARD                                                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                     │
│  │ [Icon]   │ │ [Icon]   │ │ [Icon]   │                     │
│  │ Fireball │ │ Ice Nova │ │ Black    │                     │
│  │ Tooltip  │ │ Tooltip  │ │ Hole     │                     │
│  └──────────┘ └──────────┘ └──────────┘                     │
│                                                              │
│              [CONFIRM SKILLS]                                │
└─────────────────────────────────────────────────────────────┘
```

### 8.3 Visual Feedback

| Event | Feedback |
|-------|----------|
| Damage dealt | Floating number (red), hit flash |
| Healing | Floating number (green), particle burst |
| Level up | Golden explosion, screen shake, sound |
| Skill ready | Icon glow, subtle ping sound |
| Enemy death | Death animation, gold particles |
| Low HP | Screen border red pulse, heartbeat sound |
| Victory | Confetti, victory fanfare |
| Game Over | Screen fade to black, somber music |

---

## 9. Audio Design

### 9.1 Music

| State | Music Style | Tempo |
|-------|-------------|-------|
| **Menu** | Epic orchestral, building anticipation | 90 BPM |
| **Combat** | Intense action music | 140 BPM |
| **Skill Selection** | Calm strategic music | 70 BPM |
| **Victory** | Triumphant fanfare | 120 BPM |
| **Game Over** | Somber, melancholic | 60 BPM |

### 9.2 Sound Effects

| Event | Sound |
|-------|-------|
| Attack | Sword swing, magic whoosh |
| Hit | Impact thud, armor clink |
| Skill cast | Unique per skill (explosion, chime, etc.) |
| Level up | Magical chime + orchestral hit |
| Death | Enemy-specific death sounds |
| UI click | Subtle button click |

---

## 10. Technical Specifications

### 10.1 Performance Targets

| Metric | Target |
|--------|--------|
| **Frame Rate** | 60 FPS minimum |
| **Load Time** | <3 seconds |
| **Memory Usage** | <500 MB RAM |
| **Enemy Count** | 50+ on screen simultaneously |
| **Session Length** | 15-25 minutes |

### 10.2 Platform Requirements

**Minimum:**
- OS: Windows 10
- Processor: Intel i3 or equivalent
- Memory: 4 GB RAM
- Graphics: Integrated graphics (GTX 750 or better)
- Storage: 500 MB

**Recommended:**
- OS: Windows 10/11
- Processor: Intel i5 or equivalent
- Memory: 8 GB RAM
- Graphics: Dedicated GPU (GTX 1060 or better)
- Storage: 1 GB SSD

### 10.3 Save System

**Local Save Data:**
- Meta-progression unlocks
- Achievement progress
- Settings (volume, keybinds)
- Run history (wave reached, build used)

**Cloud Save** (Future):
- Steam Cloud integration
- Cross-platform progression

---

## 11. Development Roadmap

### Phase 1: Core Loop (Current - MVP)
- [x] 3 playable heroes
- [x] Basic combat system
- [x] 10-wave progression
- [x] Skill selection system
- [x] 30+ skills implemented
- [ ] Basic UI complete
- [ ] Placeholder art replaced

### Phase 2: Polish (Next 2-4 weeks)
- [ ] Visual effects for all skills
- [ ] Sound effects and music
- [ ] UI polish and animations
- [ ] Balance pass on all skills
- [ ] Bug fixing and optimization

### Phase 3: Content (1-2 months)
- [ ] Shop system between waves
- [ ] Item/equipment system
- [ ] 3 new heroes (Knight, Archer, Necromancer)
- [ ] 30 additional skills
- [ ] Achievement system

### Phase 4: Release (2-3 months)
- [ ] Steam page setup
- [ ] Marketing materials (trailer, screenshots)
- [ ] Beta testing
- [ ] Launch on Steam/Itch.io
- [ ] Post-launch support plan

---

## 12. Monetization (Optional)

### 12.1 Recommended Model: Premium

| Model | Price | Pros | Cons |
|-------|-------|------|------|
| **Premium** | $9.99 - $14.99 | Player-friendly, complete experience | One-time purchase |
| **Free + DLC** | Free base, $5 DLCs | Larger player base, ongoing revenue | Requires more content |

**Recommendation**: Start with **Premium at $12.99** on Steam/Itch.io

### 12.2 Future DLC Ideas
- **Hero Pack 1**: Knight + Archer ($4.99)
- **Hero Pack 2**: Necromancer + Druid ($4.99)
- **Endless Mode**: Infinite waves, leaderboards ($2.99)
- **Soundtrack**: OST download ($4.99)

---

## 13. Risk Analysis

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Performance issues with many enemies** | High | Optimize rendering, use object pooling |
| **Skills not feeling impactful** | High | Add screen shake, particles, sound |
| **Builds not feeling diverse** | Medium | Playtest, add more synergies |
| **Game gets repetitive** | Medium | Add meta-progression, daily challenges |
| **Art style inconsistent** | Low | Use cohesive pixel art or simple vector style |

---

## 14. Success Metrics

### 14.1 Launch Goals
- **Steam Reviews**: 80%+ Positive
- **Wishlist Goal**: 5,000+ before launch
- **Sales Month 1**: 1,000+ copies
- **Average Playtime**: 2+ hours per player
- **Completion Rate**: 20%+ beat the game

### 14.2 Player Retention Goals
- **Session Length**: 15-25 minutes (target)
- **Sessions per Day**: 3-5 average
- **Return Rate**: 40%+ play again within 7 days

---

## 15. Appendix

### 15.1 Glossary

| Term | Definition |
|------|------------|
| **Auto-battler** | Combat happens automatically without player input |
| **Roguelike** | Procedural elements, permadeath, run-based |
| **Build** | Combination of skills and items chosen during a run |
| **Synergy** | Skills that work better together |
| **Wave** | One round of enemies |
| **Tier** | Skill level (1-3), unlocked by wave progress |
| **AoE** | Area of Effect |
| **DoT** | Damage over Time |
| **HoT** | Healing over Time |
| **CC** | Crowd Control (stun, slow, etc.) |

### 15.2 References

**Games to Study:**
1. Vampire Survivors (2022) - Power fantasy, progression
2. Brotato (2023) - Simple stats, build diversity
3. Teamfight Tactics - Team composition
4. Risk of Rain 2 - Scaling, item synergies
5. Loop Hero - Auto-combat strategy

**Design Resources:**
- "The Art of Game Design" by Jesse Schell
- GDC talks on roguelike design
- Game Maker's Toolkit (YouTube)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Initial | - | Basic concept |
| 2.0 | March 2026 | Dev Team | Complete redesign based on successful genre titles |

---

*"The secret to a great roguelike: easy to learn, hard to master, impossible to put down."*
