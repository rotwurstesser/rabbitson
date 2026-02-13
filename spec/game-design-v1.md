# Rabbitson — Game Design Spec v2

> **Status**: DRAFT — ACTIVELY SPECCING
> **Authors**: Raphael + Friend + Claude (ideation assist)
> **Date**: 2026-02-13
> **Session**: Initial ideation — mood board analysis, core systems, unit economy

---

## 1. Elevator Pitch

**Fire Emblem tactics combat inside a Slay the Spire roguelike structure, with Binding of Isaac-style item synergies and a mercenary economy where your allies are both your army and your payday.**

A dark fantasy tactics roguelike where you lead a growing warband through procedurally generated branching dungeons. Start each run with your permanent champions, recruit allies as you fight, and make impossible choices: invest in your recruits' power for harder fights, or cash them out at the end for meta-progression upgrades. Every kill levels your units individually. Every death is permanent. Every surviving recruit is gold in your pocket — if you can keep them alive.

---

## 2. Core Identity

| Attribute | Decision | Reference |
|---|---|---|
| **Genre** | Tactics Roguelike | Fire Emblem + Slay the Spire + Isaac |
| **Perspective** | Top-down (2D) | Fire Emblem GBA, Advance Wars |
| **Combat** | Turn-based grid tactics | Dynamic party size (1-6 units) vs scaled enemies |
| **Structure** | Branching path dungeon runs | Slay the Spire node map |
| **Run length** | 60-90 minutes | ~12-18 combat encounters per run |
| **Death** | Permadeath per run | Dead units are gone. No recovery. Recruit replacements. |
| **Setting** | Dark fantasy with personality | Gothic world, Rabbitson the rabbit shopkeeper, carrot-luck-crit system |
| **Engine** | Godot 4.4+ / GDScript | Signal-driven, component architecture |
| **Art style** | Pixel art (modern, 32x32+ tiles) | Polished like Octopath, classic like FE GBA |

---

## 3. Mood Board Analysis

17 reference images in `ideation/`. See Appendix A for full table.

### Art Style Target
Three tiers of aspiration from the mood board:
1. **Gameplay sprites**: Fire Emblem GBA / Advance Wars — small, readable, expressive
2. **Combat environments**: Enter the Gungeon — detailed tiles, atmospheric lighting, torches
3. **Non-combat screens**: Octopath Traveler — beautiful scenes with depth-of-field, warm lighting

---

## 4. Game Systems

### 4.1 Core Loop

```
[HUB — BETWEEN RUNS]
  View permanent roster
  Select 1-3 permanent units for starting party
  Spend CASH: buy starting recruits, items, unlock permanent units, upgrade hub
  Choose dungeon/biome
          |
          v
[RUN — BRANCHING PATH MAP]
  Navigate node map (Slay the Spire style)
  Choose path: Combat | Shop | Event | Rest | Elite | Boss
          |
          v
[COMBAT NODE]
  Turn-based tactics on scaled grid
  Party grows via mid-run recruitment
  Units level up via kills
  Loot: equipment, relics, consumables, gold
          |
          v
[REPEAT until boss or death]
          |
          v
[RUN END]
  WIN:  Surviving recruits → SOLD for cash (rarity-based value)
        Ember (meta-currency) earned based on progress
        Permanent units return to roster at level 1
        Achievement progress tracked
        Lore entries for notable unit stories
  LOSS: Reduced Ember based on floors cleared
        All recruits lost (no cash)
        Permanent units return safely
```

### 4.2 Combat System

#### Grid
Top-down square grid. Size scales with total units on field:

| Total Units (player + enemy) | Grid Size |
|---|---|
| 5-8 | 8x8 |
| 9-14 | 10x10 |
| 15-20 | 12x12 |
| 20+ | 14x14 |

#### Turn Order
Team-based alternating (Into the Breach model):
1. **Enemy Intent Phase**: Enemies telegraph their next action (target tiles highlighted in red)
2. **Player Phase**: Move and act with ALL your units in any order
3. **Enemy Execution Phase**: Enemies carry out telegraphed actions
4. Repeat

This creates a **puzzle-like feel** — you solve the board each turn with perfect information.

#### Actions Per Unit Per Turn
- 1 Move (up to MOV stat in tiles)
- 1 Action (basic attack, ability, item, or wait)
- Move and Action can happen in either order
- **Undo**: Moves can be undone freely. Actions (attacks/abilities) cannot.

#### Damage Formula
```
damage = (ATK * weapon_modifier * type_advantage) - DEF
type_advantage: 1.5x (strong), 1.0x (neutral), 0.75x (weak)
dual_advantage: weapon AND element strong = 2.0x
crit_chance = base_crit + LCK * carrot_modifier
crit_damage = damage * 1.5
```

#### Enemy Scaling (Dynamic)
Combat scales based on **party size** AND **average party level** with **variance**:

**Party size → enemy COUNT:**
| Player Units | Base Enemy Count | Notes |
|---|---|---|
| 1-2 | 3-4 | Survival mode — tight, every move matters |
| 3 | 4-6 | Standard balance point |
| 4 | 5-8 | Outnumbered but powerful |
| 5 | 7-10 | Chaotic, positioning critical |
| 6 | 8-12 | Army vs army, max scale |

**Average level vs expected → enemy QUALITY:**
- If avg party level is 2+ above biome expected level: enemy variants get tougher (more abilities, higher stats)
- Scaling has **random variance** (+-1-2 enemies per encounter) — some fights are easy, some are brutal

**Rare units do NOT increase scaling.** Rarity affects the unit's power and end-of-run cash value, not encounter difficulty. Having a rare unit should feel good, not punishing.

#### Combat Objectives (2-3 types for launch)
| Objective | Description | When it appears |
|---|---|---|
| **Rout** | Kill all enemies | Standard combat nodes (70% of encounters) |
| **Survive** | Hold out for X turns against waves | Hard combat nodes, some elites (20%) |
| **Boss** | Defeat the boss (phases, adds, terrain changes) | End of each biome (10%) |

**Bonus Objectives** (optional, extra rewards):
- "No unit takes damage" → bonus gold
- "Win in 3 turns or fewer" → bonus relic choice
- "Kill all enemies with type advantage" → bonus XP
- Bonus objectives are shown before combat. Completing them is optional but rewarding.

#### Boss Phases
Bosses have 2-3 phases:
- **Phase 1** (100-60% HP): Standard attacks, 2 adds
- **Phase 2** (60-30% HP): New ability unlocked, terrain changes (boss floods tiles, creates lava, etc.), reinforcement wave
- **Phase 3** (30-0% HP): Enraged — faster, stronger, but telegraphs become clearer (harder but fairer)

### 4.3 Unit System

#### Unit Categories

**Permanent Units** (your roster):
- Unlocked via meta-progression (achievements + cash purchases at hub)
- Pre-defined characters with names, lore, personality
- Select 1-3 to bring on each run (or fewer for challenge)
- Start each run at level 1 with base stats
- Fixed class, weapon type, element, and personal ability
- Unique growth rates per stat (FE-style percentage chances)
- **Safe across runs**: if they die in a run, they return to the roster next run at level 1
- Target: ~15-20 permanent units in the full game

**Recruited Units** (found during runs):
- Discovered mid-run: after combat clears, events, Rabbitson's shop
- Join your active party immediately
- Have a **rarity** (Common, Uncommon, Rare, Legendary) that determines:
  - Base stat quality
  - Number of starting abilities
  - End-of-run cash value when sold
- **Die = gone forever.** No recovery, no revive, no replacement (except recruiting another)
- **Survive a winning run = converted to cash** at Rabbitson's end-of-run appraisal
- Rarity-based cash values:
  - Common: 30 gold
  - Uncommon: 60 gold
  - Rare: 120 gold
  - Legendary: 250 gold

**The Core Tension**: Recruited units are simultaneously your combat power and your investment portfolio. Every recruit that dies is lost gold. Every recruit that lives through a dangerous fight is money in the bank. Do you play conservatively to protect your assets, or aggressively to clear rooms faster?

#### Max Party Size: 6
- Start a run with 1-3 permanent units
- Recruit up to 6 total units during the run
- If you find a 7th recruit and want them, you must dismiss someone
- Dismissed recruits are lost (no cash, no return)

#### Stats

| Stat | Abbrev | Description |
|---|---|---|
| Health Points | HP | 0 = dead for the run |
| Attack | ATK | Physical damage output |
| Magic | MAG | Magical damage output |
| Defense | DEF | Physical damage reduction |
| Resistance | RES | Magical damage reduction |
| Speed | SPD | Action priority within phase, dodge chance modifier |
| Movement | MOV | Tiles per turn (typically 3-5) |
| Luck | LCK | Crit chance, drop quality. Boosted by carrots. |

#### Leveling
- **XP from kills**: Killing blow = full XP. Assist (dealt damage that turn) = 50% XP.
- **Level range per run**: 1-10
- **Stat growth**: Each level-up rolls per stat (FE-style). E.g., a unit with 60% ATK growth has a 60% chance of +1 ATK per level.
- **Over-leveling trap**: Feeding all kills to one unit creates:
  - A powerhouse with weak allies who die easily
  - Higher enemy quality scaling (average level increases)
  - Catastrophic risk if that unit dies (all your eggs in one basket + lost gold if it's a recruit)

### 4.4 Ability System

Inspired by Fire Emblem Three Houses (personal + class + equipped) but simplified for roguelike pace.

#### Ability Slots (4 per unit)
| Slot | Type | Description |
|---|---|---|
| **Personal** | Innate, unique | Each unit has 1 unique ability tied to their identity. Levels up at 5 and 9. |
| **Class** | From weapon class | 1 ability tied to Melee/Ranged/Magic class. Same for all units of that class. |
| **Equipped 1** | Chosen on level-up | At level 3, choose 1 of 2 abilities. Permanent for the run. |
| **Equipped 2** | Chosen on level-up | At level 7, choose 1 of 2 abilities. Permanent for the run. |

#### Ability Costs
- Most abilities: **Free** (1 use per turn as your Action)
- Powerful abilities: **2-turn cooldown**
- Personal ability (upgraded at level 9): **3-turn cooldown**
- No mana system. Cooldowns keep it simple for the roguelike pace.

#### Equipment-Granted Abilities
Some equipment items grant additional abilities:
- "Staff of Firebolt" — grants Firebolt ability (1-2 range AoE), usable only by Magic class
- "Hunting Bow" — grants Snipe ability (4 range, ignores cover), usable only by Ranged class
- "Berserker's Axe" — grants Frenzy ability (attack twice at -30% damage), usable only by Melee class

Equipment abilities are **in addition** to the 4 slots. Having the right equipment for your class adds a 5th ability.

#### Shared vs Unique Abilities
- **Shared abilities** can appear as level-up choices for multiple units: Heal, Dodge, Jump, Shield
- **Unique abilities** are specific to one unit's personal slot: only the Shadow Knight gets "Shadow Step"
- The combination of personal + chosen abilities creates 8+ builds per unit across runs

#### Example Unit: Shadow Knight (Melee/Dark)
- **Personal (Lv 1)**: "Dark Slash" — melee attack dealing Dark damage + 10% lifesteal
  - **Upgraded (Lv 5)**: lifesteal increases to 25%
  - **Upgraded (Lv 9)**: also applies Blind (enemy misses next attack), 3-turn cooldown
- **Class**: "Guard" — reduce damage taken by 30% this turn (Melee class standard)
- **Level 3 choice**: "Shadow Step" (teleport 3 tiles) OR "Iron Will" (+20% DEF for 2 turns)
- **Level 7 choice**: "Reaper" (killing blow resets movement) OR "Dark Aura" (adjacent enemies take 2 Dark damage/turn)

### 4.5 Dual Type System

Every unit (player and enemy) has two type attributes:

#### Weapon Class (affects attack pattern and class abilities)
| Class | Strong vs | Weak vs | Attack Range |
|---|---|---|---|
| **Melee** | Ranged | Magic | Adjacent tiles (1) |
| **Ranged** | Magic | Melee | 2-3 tiles, cannot attack adjacent |
| **Magic** | Melee | Ranged | 1-2 tiles, may have AoE |

#### Element (affects damage multiplier)
| Element | Strong vs | Weak vs |
|---|---|---|
| **Fire** | Nature, Ice | Water, Earth |
| **Water** | Fire, Earth | Nature, Lightning |
| **Nature** | Water, Lightning | Fire, Ice |
| **Lightning** | Water, Ice | Earth, Nature |
| **Earth** | Lightning, Fire | Water, Nature |
| **Ice** | Nature, Fire | Water (special: freezes water tiles) |
| **Light** | Dark | Dark |
| **Dark** | Light | Light |

**Dual advantage** (both weapon AND element strong) = 2.0x damage multiplier.
**Dual disadvantage** = 0.5x. This makes squad composition matter enormously.

### 4.6 Terrain System

| Terrain | Movement Cost | Effect |
|---|---|---|
| **Plains** | 1 | None |
| **Forest** | 2 | +20% DEF, blocks ranged line of sight |
| **Water** | 3 (or impassable) | Water units: +ATK, normal cost. Non-water: impassable or 3 cost |
| **Mountain** | Impassable | Flying units only |
| **Ruins** | 1 | +10% DEF, can be destroyed by AoE |
| **Lava** | 1 | 15% max HP damage/turn. Fire units immune. |
| **Sand** | 2 | -1 MOV while standing on it |
| **Ice** | 1 | Units slide 1 extra tile. Ice units immune to slide. |

Terrain ties into the element system and biome identity. Water biome = lots of water tiles favoring Water units. Ashlands = lava everywhere favoring Fire units.

### 4.7 Reward System

After each combat encounter, choose 1 of 3 random rewards:

#### Equipment (per-unit, 3 slots)
- **Weapon**: Base ATK/MAG, may grant bonus ability (class-restricted)
- **Armor**: Base DEF/RES, may have passive effect
- **Accessory**: Special effect (ring of haste: +1 MOV, amulet of thorns: reflect 10% damage)

#### Relics (Slay the Spire style, stack globally or per-unit)
Primary synergy engine. Examples:
- "Burning Touch" — Melee attacks apply Burn (2 dmg/turn, 3 turns)
- "Chain Lightning" — Lightning damage jumps to 1 adjacent enemy at 50%
- "Carrot of Fortune" — +5 LCK to all units
- "Glass Cannon" — +50% ATK, -30% DEF
- "Vampiric Edge" — Killing blows heal attacker 20% of damage dealt
- "Merchant's Blessing" — Recruited units are worth +25% more gold at end of run

**Synergy combos** (the Isaac hook):
- "Burning Touch" + "Oil Slick" = fire + water terrain = double fire damage
- "Chain Lightning" + "Conductive Armor" = AoE stun chain
- "Vampiric Edge" + "Glass Cannon" = high risk, high sustain
- "Merchant's Blessing" + recruiting aggressively = investment build

#### Consumables (3 inventory slots max)
- **Health Potion**: Heal 1 unit 50% HP
- **Teleport Stone**: Move 1 unit to any tile (next combat)
- **Type Shift Crystal**: Change 1 unit's element (next combat)
- **Carrot**: +2 LCK permanently for the run (Rabbitson special)

### 4.8 Overworld / Branching Path Map

Slay the Spire-style branching map, themed per biome.

```
        [BOSS]
       /      \
    [Elite]  [Event]
    /    \      |
 [Fight] [Shop] [Fight]
    \    /    \    /
   [Fight]  [Rest]
      \      /
     [Fight]
        |
     [START]
```

**Node types**:
| Node | Description |
|---|---|
| **Combat** | Standard tactics encounter. Reward + gold + possible recruit after clearing. |
| **Elite** | Harder encounter, better rewards, guaranteed rare recruit chance. |
| **Boss** | End-of-biome fight. Must defeat to advance. 2-3 phases. |
| **Shop** | Rabbitson's shop. Buy equipment, relics, consumables, sometimes recruits. |
| **Rest** | Heal all units. Choose: Heal (full HP) OR Upgrade (enhance 1 equipment). |
| **Event** | Random narrative event. May grant rewards, offer recruits, present dilemmas. |
| **Mystery** | Unknown until entered. Could be any of the above. |

**Run structure**:
- Full run = 3 biomes (acts)
- Each biome = ~5-7 nodes before boss
- Total: ~15-21 nodes, ~12-18 combats
- Combat timing: 5-7 min (small party), 10-15 min (large party), 15-20 min (boss)

### 4.9 Event System

Events are floor-specific, drawn from weighted pools. No repeats within a run.

**Event categories**:
| Category | Frequency | Description |
|---|---|---|
| **Recruitment** | 30% | A unit offers to join. Accept = new party member. Decline = small gold reward. |
| **Gamble** | 25% | Risk/reward choices. "Drink the strange potion?" → might boost stats or curse a unit. |
| **Trade** | 20% | Exchange resources. HP for gold, gold for relics, sacrifice a relic for a better one. |
| **Lore** | 15% | Narrative moment. Learn about the world, Rabbitson's backstory, dungeon history. Small stat buff. |
| **Shrine** | 10% | Powerful but costly. "Sacrifice 25% max HP permanently for +3 ATK for the run." |

**Design rules** (learned from Slay the Spire):
- Every choice costs something. No "free pass" options.
- Event value depends on current game state (low HP makes heal events worth more, full party makes recruitment less useful)
- Target: ~30-40 events for launch, expandable

### 4.10 Unit Economy + Meta-Progression

#### In-Run Economy: Gold
- Earned from: combat clears, bonus objectives, selling unwanted equipment, events
- Spent at: Rabbitson's in-run shop (equipment, relics, consumables, sometimes recruits)
- Does NOT persist between runs

#### End-of-Run Economy: Cash (from recruit appraisal)
- When you WIN a run, Rabbitson appraises surviving recruited units
- Cash value is determined by recruit rarity (see 4.3)
- This cash goes to your persistent hub wallet

#### Meta-Currency: Ember
- Earned every run (win or lose) based on: biomes cleared, bosses beaten, bonus objectives, units recruited
- Winning earns significantly more than losing
- Spent at the hub alongside cash

#### Hub Spending
| Purchase | Currency | Description |
|---|---|---|
| **Unlock permanent unit** | Ember (expensive) | Pre-defined characters. Achievement-gated or Ember-purchased. |
| **Buy starting recruits** | Cash (moderate) | Hire mercenaries to start next run with. They're recruited units (still sold at end). |
| **Buy starting items** | Cash (cheap) | Begin a run with a specific weapon, relic, or consumable. |
| **Upgrade hub** | Ember (scaling) | Expand Rabbitson's shop inventory, unlock new event types, improve recruit quality. |
| **Difficulty: Corruption** | Free (toggle) | Increase difficulty for better rewards and harder challenges. |

#### Difficulty System: Corruption (Hades Heat Model)
After first win, unlock Corruption levels (1-20). Each adds a modifier:
- C1: Enemies +10% HP
- C2: Shop prices +20%
- C3: 2 reward choices instead of 3
- C4: Elite enemies appear in standard combat nodes
- C5: Bosses gain extra phase
- C6: More hazard terrain
- C7: Start with 1 curse relic
- ...
- C20: Maximum difficulty, special cosmetic unlock

Corruption levels are **toggleable** independently or cumulatively. Self-directed difficulty.

### 4.11 Rabbitson (The Shopkeeper)

A mysterious rabbit-like merchant who appears in every run's shop nodes and at the end-of-run appraisal.

**Personality**: Enigmatic, mischievous. Speaks in riddles and puns. Obsessed with carrots. Always offers "fair" deals that feel slightly suspicious.

**The Carrot-Luck-Crit System**:
- Carrots are a consumable sold by Rabbitson and found in events
- Eating a carrot: +2 LCK permanently for the run
- LCK → crit chance (each LCK point = +1% crit)
- Carrot-synergy relics:
  - "Golden Carrot" — Doubles LCK bonus from carrots
  - "Rabbit's Foot" — Start each combat with +3 LCK for 2 turns
  - "Carrot Cake" — Heal 10 HP + gain 2 LCK (consumable)
  - "Merchant's Nose" — Rabbitson's shop always offers 1 carrot for free

**Lore thread**: Why does a rabbit sell weapons in dark fantasy dungeons? Rabbitson hints at a deeper story. Lore events reveal fragments. The full truth is end-game content.

### 4.12 Unit Stories + Lore System

Recruited units are not just disposable assets — they generate **micro-narratives**:

**During a run:**
- Recruited units have procedurally generated names and brief backstories
- "Kael, a wandering Fire Mage who lost his village to the Lich King"
- Key combat moments are logged: "Kael killed the Lich King's lieutenant" / "Kael fell in battle against Sea Serpents"

**End of run:**
- **Survivors** who are sold: "Kael left the warband with 120 gold and a story to tell"
- **Fallen units**: Added to a "Memorial" wall at the hub. Their name, class, and how they died.
- **Notable recruits**: Units that got killing blows on bosses, survived at 1 HP, or achieved bonus objectives get special memorial entries

This adds emotional weight to the mercenary economy. Selling Kael for 120 gold after he carried you through the Crypt boss? That should feel meaningful.

---

## 5. Biomes (Initial 3)

### Biome 1: The Crypt
- **Terrain**: Stone, pillars (LoS blockers), coffins (destructible cover), darkness
- **Enemies**: Skeletons (Melee/Dark), Wraiths (Magic/Dark), Bone Archers (Ranged/Dark)
- **Boss**: The Lich King — summons adds, AoE dark magic, 3 phases
- **Recruitable**: Undead Knight (Melee/Dark, Uncommon), Spirit Healer (Magic/Light, Rare)
- **Mood**: Darkest Dungeon meets Enter the Gungeon

### Biome 2: The Depths
- **Terrain**: Water (abundant), coral (cover), whirlpools (pull effect), sand, submerged ruins
- **Enemies**: Sea Serpents (Melee/Water), Sirens (Magic/Water), Harpoon Hunters (Ranged/Ice)
- **Boss**: The Leviathan — tidal waves flood tiles, high HP, spawns adds from water
- **Recruitable**: Sea Spirit (Magic/Water, Rare), Coral Golem (Melee/Earth, Uncommon)
- **Mood**: Mysterious, bioluminescent, deep blue

### Biome 3: The Ashlands
- **Terrain**: Lava, scorched earth, obsidian pillars, ash clouds (vision block)
- **Enemies**: Fire Golems (Melee/Fire), Ember Mages (Magic/Fire), Ash Snipers (Ranged/Fire)
- **Boss**: The Infernal — creates lava dynamically, buffs fire enemies, eruption phases
- **Recruitable**: Magma Elemental (Melee/Fire, Legendary), Phoenix Scout (Ranged/Fire, Uncommon)
- **Mood**: Apocalyptic, red/orange, crumbling

---

## 6. Technical Architecture

### Key Reference Projects
| Project | URL | Why |
|---|---|---|
| **godot-tactical-rpg** | [github](https://github.com/ramaureirac/godot-tactical-rpg) | Best-documented Godot 4 tactics. Service-oriented, Resource-based state. |
| **unto-deepest-depths** | [github](https://github.com/theshaggydev/unto-deepest-depths-prototype) | Godot 4 tactics roguelite. Composition-based units, signal-driven. |
| **The Liquid Fire** | [tutorials](https://theliquidfire.com/category/projects/godot-tactics/) | 18-lesson series: FSM, turn order, items, abilities, status effects. |
| **GDQuest Movement** | [tutorial](https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/) | Resource-based Grid, AStar2D pathfinding. |

### Architecture Patterns
- **Grid**: Resource-based Grid + AStarGrid2D (Godot 4 native)
- **Units**: Composition over inheritance. Controllers: Stats, Actions, AI
- **Turns**: Team-based alternating with enemy telegraphing
- **Buffs**: ModiBuff or EnhancedStat addon for modifier stacking
- **Proc Gen**: Template-based arenas + procedural enemy/terrain placement
- **Overworld**: Node graph (Slay the Spire style)
- **Combat FSM**: Idle → SelectUnit → SelectAction → SelectTarget → Execute → EnemyPhase → CheckWinLose

### Into the Breach Design Lessons
1. **Perfect information** via telegraphing
2. **Minimal RNG** — fixed damage, RNG only for spawns/layouts/rewards
3. **Every death is the player's fault**
4. **Undo within turn** (moves yes, actions no)
5. **Small grids** — every tile matters

### Godot Addons to Evaluate
- [ModiBuff](https://godotengine.org/asset-library/asset/2166) — Buff/debuff stacking
- [EnhancedStat](https://github.com/Zennyth/EnhancedStat) — Stat modifiers
- [Godot Gameplay Systems](https://godotengine.org/asset-library/asset/932) — Attributes, abilities, equipment
- [WFC Plugin](https://github.com/AlexeyBond/godot-constraint-solving) — Procedural terrain

---

## 7. Comparable Games Matrix

| Game | Grid | Roguelike | Unit Mgmt | Synergies | Types | What Rabbitson adds |
|---|---|---|---|---|---|---|
| **Into the Breach** | 8x8, 3 mechs | Per-run | Pilots persist | Equipment only | None | Unit leveling, item synergies, type matchups, recruit economy |
| **Fire Emblem** | Large, army | Linear campaign | Deep building | Equipment | Weapon triangle | Roguelike loop, synergies, procedural maps, recruit economy |
| **Slay the Spire** | None (cards) | Branching map | Solo | Relic combos | None | Grid tactics, multi-unit, type system, recruit economy |
| **Darkest Dungeon** | None (positional) | Expeditions | Party of 4 | Trinkets | None | Grid tactics, synergies, type system, recruit economy |
| **Hades** | Arena action | Room rewards | Solo | Boon combos | None | Tactics, party management, recruit economy |

**Unique value**: The ONLY game combining grid tactics + roguelike runs + growing warband + recruit-as-currency economy + deep item synergies + dual type system.

---

## 8. Open Questions

### Design (resolve before implementation)
- [ ] How exactly does the carrot economy integrate with gold? Sub-currency or just a consumable?
- [ ] Should players see the full branching map at run start, or reveal per biome?
- [ ] Class promotion? Can units change weapon class mid-run? Or fixed?
- [ ] How many abilities can equipment grant? Cap at 1 per equipment?
- [ ] Multiplayer — ever on the table, or strictly single-player?
- [ ] Can you voluntarily dismiss permanent units from roster? Or once unlocked, always there?

### Art (resolve before asset creation)
- [ ] Pixel art density: 16x16 tiles vs 32x32?
- [ ] Character portraits for unit stat screens?
- [ ] Animation: frame-by-frame or tweened?
- [ ] UI: diegetic (Inscryption) or clean overlay (Slay the Spire)?

### Technical (resolve before architecture)
- [ ] Save system: save between nodes? Only at rest? Suspend-save (quit + resume)?
- [ ] Proc gen: WFC, BSP, or template-based?
- [ ] Target platform: desktop only? Mobile? Web?

---

## 9. MVP Scope (v0.1)

Playable vertical slice:

- [ ] 1 biome (The Crypt), 5 combat encounters + 1 boss
- [ ] 2 permanent units (1 Melee, 1 Ranged or Magic)
- [ ] Recruitment: 1-2 recruitable units during the run
- [ ] Grid combat: movement, basic attack, 1 ability per unit
- [ ] Turn system with enemy telegraphing
- [ ] 3 enemy types + 1 boss (2 phases)
- [ ] Simple branching map (5 nodes: 3 combat, 1 shop, 1 boss)
- [ ] 5 equipment pieces, 3 relics, 2 consumables
- [ ] Rabbitson's shop (buy with gold)
- [ ] End-of-run recruit appraisal (sell for cash)
- [ ] Permadeath within run
- [ ] Basic terrain (plains, forest, ruins)
- [ ] Win/lose condition + return to hub
- [ ] Hub: roster view, cash wallet, start next run

**NOT in MVP**: Full meta-progression, multiple biomes, corruption system, events, rest nodes, save system, full type system (weapon triangle only), lore/memorial system.

---

## 10. Reference Links

### Architecture
- [ramaureirac/godot-tactical-rpg](https://github.com/ramaureirac/godot-tactical-rpg)
- [unto-deepest-depths-prototype](https://github.com/theshaggydev/unto-deepest-depths-prototype)
- [The Liquid Fire Godot Tactics RPG](https://theliquidfire.com/category/projects/godot-tactics/)
- [GDQuest Tactical RPG Movement](https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/)
- [Into the Breach GDC Postmortem (PDF)](https://ubm-twvideo01.s3.amazonaws.com/o1/vault/gdc2019/presentations/Into%20the%20Breach%20Postmortem%20Final.pdf)

### Godot Addons
- [ModiBuff](https://godotengine.org/asset-library/asset/2166)
- [EnhancedStat](https://github.com/Zennyth/EnhancedStat)
- [Godot Gameplay Systems](https://godotengine.org/asset-library/asset/932)
- [WFC Plugin](https://github.com/AlexeyBond/godot-constraint-solving)

### Design Analysis
- [Into the Breach — Enemy Intentions](https://atomicbobomb.home.blog/2020/05/17/into-the-breach-enemy-intentions/)
- [Into the Breach — UX Makes You Feel Smart](https://blog.prototypr.io/into-the-breachs-ux-makes-you-feel-smart-a9cb03210757)
- [Reimagining Failure in Strategy Games](https://www.gamedeveloper.com/design/reimagining-failure-in-strategy-game-design-in-i-into-the-breach-i-)
- [FE Three Houses Abilities](https://serenesforest.net/three-houses/miscellaneous/abilities/)
- [FE Engage Inherited Skills](https://www.gamerguides.com/fire-emblem-engage/guide/somniel/ring-chamber/how-to-unlock-and-equip-inherited-skills-in-fire-emblem-engage)
- [Slay the Spire Events](https://slaythespire.wiki.gg/wiki/Events)
- [XCOM 2 Mission Types](https://xcom.fandom.com/wiki/Missions_(XCOM_2))
- [Invisible Inc. Missions](https://invisibleinc.fandom.com/wiki/Missions)

---

## Appendix A: Full Mood Board Inventory

| Image | Game | Category | What it contributes |
|---|---|---|---|
| `fire emblem.jpg` | Fire Emblem GBA | Tactics Core | Grid map, unit sprites, movement cursor |
| `fire emblem2.jpg` | Vestaria Saga / FE-like | Tactics Core | Movement range overlay, stats panel, terrain info |
| `fftactics.jpeg` | Final Fantasy Tactics | Tactics Core | Isometric grid (aesthetic inspiration) |
| `FyHDpZyhXkRPhArJfXYAXP-1200-80.jpg` | FFT (high-res) | Tactics Core | Lush terrain, unit diversity |
| `GBA_Advance_Wars.jpg` | Advance Wars | Tactics Core | Clean pixel grid, readable icons, terrain variety |
| `hades-ii_k2e3.1920.jpg` | Hades II | Roguelike Loop | Room-clearing, boss bars, ability loadout |
| `1758814531042_1758814531042.jpg` | Hades II | Roguelike Loop | Multi-character combat, environmental FX |
| `isaacrebirth.0.0.1487720988.jpg` | Binding of Isaac | Roguelike Loop | Top-down rooms, simple sprites, minimap |
| `inscryption.jpg` | Inscryption | Roguelike Loop | Branching path overworld map |
| `inscryption2.jpeg` | Inscryption | Roguelike Loop | Biome-themed map ("The Wetlands") |
| `brotaato.jpg` | Brotato | Power Fantasy | Damage numbers, item stacking, becoming powerful |
| `roguelike-brotato.jpg` | Brotato | Power Fantasy | Higher level chaos, run progression |
| `Free-Roguelike-Shoot-em-up-Pixel-Art-Game-Kit2-720x480.jpg` | Pixel art kit | Power Fantasy | Multiple weapons, vibrant pixel art |
| `Hard-Modern-Roguelike-Game-Darkest-Dungeon-1024x576.jpg` | Darkest Dungeon | Atmosphere | Party combat, detailed stats, gothic mood |
| `enter the gungeon.jpg` | Enter the Gungeon | Atmosphere | Dungeon room, destructible env, pixel tiles |
| `maxresdefault.jpg` | Octopath Traveler II | Visual Aspiration | HD-2D quality target |
| `P4_1-hk9egougw.jpg` | HD-2D village | Visual Aspiration | Warm detailed pixel environments |
