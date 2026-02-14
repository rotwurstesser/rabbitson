# Rabbitson — Game Design Spec v2

> **Status**: DRAFT — ACTIVELY SPECCING
> **Authors**: Raphael + Friend + Claude (ideation assist)
> **Date**: 2026-02-13
> **Session**: Full design survey — 17 rounds of Q&A covering all major systems

---

## 1. Elevator Pitch

**Fire Emblem tactics combat inside a Binding of Isaac roguelike structure, with deep relic synergies and a mercenary economy where every unit is both your sword and your payday.**

A dark fantasy tactics roguelike where you lead a growing warband through procedurally generated branching dungeons. Every unit is temporary — recruited mid-run, expendable, and sold to a mysterious rabbit shopkeeper at the end. Build your bench of saved units across runs, discover game-breaking relic combos through knowledge and luck, and push deeper into harder content for better rewards. Death is permanent. Gold is scarce. And Rabbitson's deals always feel slightly wrong.

---

## 2. Core Identity

| Attribute | Decision | Reference |
|---|---|---|
| **Genre** | Tactics Roguelike | Fire Emblem + Isaac + Slay the Spire |
| **Perspective** | Top-down (2D) | Fire Emblem GBA, Advance Wars |
| **Art Style** | Limbo-style silhouettes | Monochromatic, atmospheric, AI-generated |
| **Combat** | Turn-based grid tactics, FE-style moderate RNG | Dynamic party size (1-6 units) vs scaled enemies |
| **Structure** | Branching path dungeon runs with exit gates | Isaac-style "continue deeper" |
| **Run length** | Variable: 60 min (early exit) to 3+ hours (full deep run) | Exit after any biome boss |
| **Death** | Full permadeath, no permanent units | Dead units are gone. Bench is one-use. |
| **Tone** | Dark with levity (Hades) | Gothic world, unsettling Rabbitson, humor in darkness |
| **Difficulty** | One mode: Classic | Save between nodes, deleted on load. Corruption for scaling. |
| **Engine** | Godot 4.4+ / GDScript | Signal-driven, component architecture |
| **Multiplayer** | Never. Strictly solo. | |

---

## 3. Art Direction

### Style: Limbo-Inspired Silhouettes

The game uses a monochromatic silhouette art style inspired by Playdead's LIMBO:
- **Palette**: Black, white, and shades of gray TODO if you are a human or AI,we need to update this.
- **Characters**: Dark silhouettes with minimal internal detail (glowing eyes, visible weapons)
- **Environments**: Atmospheric fog layers, directional lighting, shadow pools
- **UI**: Clean overlay (Slay the Spire / Fire Emblem style) — functional, readable, separate from the art

### Top-Down Adaptation

LIMBO is a side-scroller. Adapting to top-down tactics requires:
- Characters distinguished by **shape silhouette** from overhead (bulky = Vanguard, thin = Marksman, robed = Caster, small/agile = Scout)
- Grid tiles use subtle gray variation for terrain differentiation
- Fog of war (when active) integrates naturally with the atmospheric style
- Lighting from above/angle rather than behind

### Constraint: AI-Generated Assets

**All game art assets will be generated using AI tools.** This is a hard production constraint.

#### Recommended Pipeline
1. **Concept/Ideation**: Nano Banana (Google Gemini 2.5 Flash Image) or Midjourney for mood boards and silhouette mockups
2. **Production Sprites**: PixelLab or Stable Diffusion + ControlNet with a custom-trained LoRA on first 10-20 hand-drawn reference silhouettes
3. **Animation Frames**: Dzine AI or PixelLab for frame-by-frame generation with pose editors for consistency
4. **Manual Cleanup**: Budget 20% time for human refinement (alignment, pixel perfection, looping)

#### Feasibility Notes
- Monochromatic silhouettes are **theoretically easier** for AI (fewer variables: no color palette drift, rough edges read as atmospheric)
- **No existing top-down tactics game uses pure silhouette style** — prototype early to test readability
- AI animation gets ~80% there; humans handle final 20%
- Consider 4-directional sprites (N/E/S/W) instead of 8 to reduce asset count
- Train a custom LoRA on your own silhouette style after creating 10-20 reference assets

#### Animation Style
Frame-by-frame (classic), FE GBA-inspired. 4-8 frames per action. Tactics games need fewer animations than action games (idle, walk, attack, ability, hit, death).

#### Key Research Links
- [PixelLab](https://www.pixellab.ai/) — AI pixel art and sprite sheet generation
- [Dzine AI](https://www.dzine.ai/tools/ai-sprite-generator/) — character-consistent sprite sheets
- [Scenario](https://help.scenario.com/en/articles/create-spritesheets-with-scenario/) — style-locked asset generation
- [Stable Diffusion Pixel Art Tutorial](https://www.toolify.ai/ai-news/create-pixel-art-for-games-with-comfyui-and-stable-diffusion-3482732)

---

## 4. Game Systems

### 4.1 Core Loop

```
[BASE CAMP — BETWEEN RUNS]
  View bench (saved units from previous runs)
  Pick 3 units: from bench (one-use) or Rabbitson's free C-tiers
  Buy starting loadout from Rabbitson's pre-run shop (procedurally random)
  Spend Cash/Ember: hub upgrades, starting items, content unlocks
          |
          v
[RUN — BRANCHING PATH MAP]
  Navigate node map (Slay the Spire style)
  Choose path: Combat | Shop | Event | Rest | Elite | Boss | Mystery
  Biome order is RANDOM each run
          |
          v
[COMBAT NODE]
  Deployment phase: place units in zone (shape varies by map)
  Blind entry: enemy composition unknown until combat starts
  Turn-based tactics on scaled grid
  Units level up via kills
  Loot: equipment, relics, consumables, gold
          |
          v
[REPEAT until boss]
          |
          v
[BIOME BOSS]
  Unique boss per biome, 3 phases
  After boss: choose EXIT (cash out) or CONTINUE DEEPER
  Hidden paths: secret map nodes (luck-gated) + boss portals (RNG)
          |
          v
[RUN END]
  EXIT (after any boss):
    All surviving units → SOLD to Rabbitson for cash
    Cash value = rarity base + level bonus + milestone bonuses
    Ember earned based on progress
    Deeper runs earn a reward MULTIPLIER (1.5x after Biome 2, 2.0x after Biome 3)
  DEATH:
    Reduced Ember based on floors cleared
    All units lost (no cash)
    Equipment lost with units
  DECLINED RECRUITS during run → sent to bench (except S-tier)
```

### 4.2 Unit System

#### No Permanent Units

All units are temporary. There is no persistent roster of safe characters.
- **Bench**: Your saved units from previous runs. Limited slots (start 2, upgrade to 6). One-use: a benched unit used in a run is consumed regardless of outcome.
- **Rabbitson's Safety Net**: If bench has < 3 units, Rabbitson provides free C-tier units to fill your starting squad of 3.
- **No unit survives across runs.** Survivors are sold. The bench is stocked only from declined mid-run recruits.

#### Tier System (C/B/A/S)

Tier IS the class variant. Higher tier = same archetype, better stats, more abilities. No separate rarity system.

| Tier | Quality | Bench Rules | On Decline |
|---|---|---|---|
| **C-tier** | Basic class variant, low stats, 1-2 abilities | Can bench | Disappears |
| **B-tier** | Improved variant, moderate stats, 2-3 abilities | Can bench | Disappears |
| **A-tier** | Strong variant, high stats, 3-4 abilities | Can bench | Disappears |
| **S-tier** | Legendary variant, top stats, unique mechanics | **CANNOT bench** | Drops a themed legendary item |

S-tier units cannot be hoarded. Finding one is never wasted (you get a powerful item even if you decline), but you can't stockpile them for future runs.

#### Four Archetypes (× 4 Tiers = 16 Unit Types)

| Archetype | Role | Weapon Class | Tier Examples (C → S) |
|---|---|---|---|
| **Vanguard** | Front line tank/damage | Melee | Footsoldier → Sentinel → Warlord → Champion |
| **Marksman** | Back line physical damage | Ranged | Archer → Longbow → Crossbow → Sniper |
| **Caster** | Magic damage + support | Magic | Apprentice → Mage → Warlock → Archmage |
| **Scout** | Speed/luck/recon/crit | Melee/Ranged hybrid | Thief → Ranger → Assassin → Phantom |

Higher tiers have the same core archetype identity but better stats, more ability slots, and potentially unique passives.

#### Recruit Identity

Every recruit has:
- **Procedural name** and brief backstory
- **Personality traits** (gameplay-affecting): Brave (+ATK when outnumbered), Greedy (+gold on kill), Coward (-ATK at low HP), Lucky (+LCK), etc.
- **Combat barks** (text reactions): lines on crit, death, low HP, ally death, boss encounter
- **Combat log**: key moments tracked ("killed the Lich King's lieutenant", "survived at 1 HP")

#### Max Party Size: 6

- Start a run with 3 units (from bench + Rabbitson's C-tiers)
- Recruit up to 6 total during the run
- If you find a 7th: swap (remove one from party) or decline (send to bench if not S-tier)
- Dismissed/swapped units during a run are gone (no cash, no bench)

#### Stats

| Stat | Abbrev | Description |
|---|---|---|
| Health Points | HP | 0 = dead for the run. Equipment lost. |
| Attack | ATK | Physical damage output |
| Magic | MAG | Magical damage output |
| Defense | DEF | Physical damage reduction |
| Resistance | RES | Magical damage reduction |
| Speed | SPD | Action priority within phase, dodge chance modifier |
| Movement | MOV | Tiles per turn (typically 3-5) |
| Luck | LCK | Loot quality, recruit quality, hidden path discovery. Party LCK = **average** of all units. |
| Critical | CRIT | Critical hit chance. Separate from LCK. |

**LCK and CRIT are separate stats.**
- LCK: meta-reward stat. Affects drop quality, recruit tier chances, hidden path visibility. Most units have low LCK (~0.2/10). Specialist Scouts may have 2+.
- CRIT: combat stat. Determines critical hit probability. Boosted by equipment and abilities, not carrots.

**Adding low-LCK units to the party dilutes average party LCK.** This creates a composition trade-off: do you bring the fragile lucky Scout for better drops, or a tanky Vanguard for safer combat?

#### Leveling
- **XP from kills**: Killing blow = full XP. Assist (dealt damage that turn) = 50% XP.
- **Level range per run**: 1-10
- **Stat growth**: Each level-up rolls per stat (FE-style percentages)
- **Level-up ability choices**: At specific levels, choose 1 of 2 abilities

#### Cash Value Formula
Surviving units sold at run end. Value = base (by tier) + level bonus + milestone bonuses.

**Base value by tier:**
| Tier | Base Cash |
|---|---|
| C | 30 gold |
| B | 60 gold |
| A | 120 gold |
| S | 250 gold |

**Level bonus**: +5 gold per level above 1 (level 8 C-tier = 30 + 35 = 65 gold)

**Milestone bonuses** (cumulative):
- First kill in a run: +10 gold
- Boss killing blow: +50 gold
- Survived at 1 HP: +20 gold
- Completed a bonus objective: +15 gold

### 4.3 Combat System

#### Philosophy
FE-style tactics with moderate RNG. **Not** ITB-style perfect-information puzzles. Combat is about reading the battlefield, adapting under uncertainty, and managing risk.

#### Grid
Top-down square grid. Size scales with total units on field:

| Total Units (player + enemy) | Grid Size |
|---|---|
| 5-8 | 8x8 |
| 9-14 | 10x10 |
| 15-20 | 12x12 |
| 20+ | 14x14 |

#### Deployment Phase
Before each combat, the player places their units in a **deployment zone**:
- Zone shape varies by map (2 rows on edge, corner, corridor, split across two sides)
- Placement is strategic: archers behind, tanks front
- Enemy composition is UNKNOWN at deployment (blind entry)
- Some enemies (assassins, flankers) may spawn behind the expected front line

#### Turn Order
Team-based alternating: If you are an AI or Human, this needs to be refined. Do we need a Initiative System?
1. **Player Phase**: Move and act with ALL your units in any order
2. **Enemy Phase**: Enemies act (no telegraphing — observe, adapt, react)
3. Repeat

#### Enemy Information
- **Hover**: See enemy movement range + attack range
- **Right-click inspect**: See base stats (ATK, DEF, etc.)
- **Hidden**: Buffs and debuffs may not be visible
- **First encounter**: New enemy types show "???" stats until you fight them once (persists in bestiary across runs)

#### Actions Per Unit Per Turn
If you are an AI ou Human, this needs to be refined. Do we only allow one action. Do we need some abilites that count as bonus action or some kind of mana system that allows more than one action in one turn.
- 1 Move (up to MOV stat in tiles)
- 1 Action (basic attack, ability, item, or wait)
- Move and Action can happen in either order
- **Undo**: Moves can be undone freely. Actions (attacks/abilities) cannot.

#### Damage Formula
```
damage = (ATK * weapon_modifier * type_advantage) - DEF
```

**Moderate RNG**: Hit rates (~85-100%), dodge chance (SPD-based), critical hits (CRIT stat).
- Crits deal 1.5x damage
- Misses are possible but uncommon for most attacks
- Type advantage modifiers create dramatic damage swings

#### Enemy Scaling (Dynamic)
Combat scales based on **party size** AND **average party level** with **variance**:

- Party size → enemy COUNT (more units = more enemies)
- Average level vs expected → enemy QUALITY (overleveled = tougher enemy variants)
- Random variance ±1-2 enemies per encounter
- S-tier units do NOT increase scaling (finding one should feel good, not punishing)

#### Combat Objectives (3 types for launch)
| Objective | Description | Frequency |
|---|---|---|
| **Rout** | Kill all enemies | ~70% of encounters |
| **Survive** | Hold out for X turns against waves | ~20% |
| **Boss** | Defeat the boss (3 phases, adds, terrain) | ~10% |

**Bonus Objectives** (optional, shown before combat):
- "No unit takes damage" → bonus gold
- "Win in 3 turns or fewer" → bonus relic choice
- "Kill all enemies with type advantage" → bonus XP

#### Healing in Combat
Multiple healing sources exist:
- Healing potions (consumable, limited inventory)
- Caster support abilities (heal/shield allies)
- Lifesteal relics (heal on kill/damage)
- Equipment with HP regen effects

#### Death in Combat
If you are an AI or Human, this needs to be refined. Maybe there is a rare item, that prevents death but the item gets disroid.
- Unit dies → gone permanently
- **Equipment is lost with the unit** (not recovered)
- Adds to memorial + combat log
- If ALL units die → run ends in defeat

#### Fog of War
**Event modifier only** (~20% of fights). Not universal. When active:
- Tiles beyond unit vision range are hidden
- Enemies are invisible until discovered
- Scout archetype has extended vision range
- Creates tension and surprise encounters

#### Static Terrain
Terrain is placed at combat start and does not change during combat. No board manipulation mechanics (no pushing enemies, no creating tiles).

### 4.4 Type System

#### Design Philosophy
Type interactions should feel **logical**, not arbitrary. Armor type affects how damage is received. Not a simple multiplication table.

#### Four Elements at Launch
If you are an AI or human, this needs to be refined. Dark is currently strong vs two alements, making it the strongest element. Do we want that, or do we need a 6 element like light?
| Element | Strong vs | Weak vs |
|---|---|---|
| **Fire** | Nature | Water |
| **Water** | Fire | Nature |
| **Nature** | Water | Dark |
| **Dark** | Nature | Fire |

Additional elements (Lightning, Earth, Ice, Light) added post-launch.

#### Weapon/Armor Interactions
Damage type (slash, pierce, magic) interacts with armor type (plate, leather, cloth, natural):
- Arrows bounce off plate armor (reduced damage)
- Blades cut through cloth (increased damage)
- Magic ignores physical armor (targets RES instead of DEF)
- Lightning conducts through metal armor (bonus damage to plate-wearers)
- Logical, learnable interactions — not arbitrary charts

**Dual advantage** (weapon AND element strong) provides a significant damage bonus. Squad composition matters.

### 4.5 Ability System

#### Ability Slots (up to 4 per unit, scales with tier)
| Tier | Slots | Structure |
|---|---|---|
| C | 1-2 | Personal + maybe 1 class ability |
| B | 2-3 | Personal + class + 1 level-up choice |
| A | 3-4 | Personal + class + 2 level-up choices |
| S | 4 + unique passive | Full kit + tier-exclusive mechanic |

#### Ability Costs
If you are an AI or Human, this needs to be refined. Do we have cooldown or mana system?
- Most abilities: Free (1 use per turn as your Action)
- Powerful abilities: 2-turn cooldown
- Ultimate abilities (S-tier): 3-turn cooldown
- No mana system. Cooldowns keep it simple.

#### Equipment-Granted Abilities
Some equipment grants an additional ability beyond the slots. Class-restricted.

### 4.6 Terrain System

Static terrain, set at combat start:

| Terrain | Movement Cost | Effect |
|---|---|---|
| **Plains** | 1 | None |
| **Forest** | 2 | +20% DEF, blocks ranged line of sight |
| **Water** | 3 (or impassable) | Water units: +ATK, normal cost. Others: impassable or 3 cost |
| **Mountain** | Impassable | Flying units only |
| **Ruins** | 1 | +10% DEF |
| **Lava** | 1 | 15% max HP damage/turn. Fire units immune. |
| **Sand** | 2 | -1 MOV while standing on it |
| **Ice** | 1 | Units slide 1 extra tile. Ice units immune (post-launch element). |

Terrain ties into biome identity and element system.

### 4.7 Relic System

**The primary synergy engine. The path to "becoming broken."**

#### Target: 100+ Relics at Launch

Relics are the game's deepest system. Finding the right 2-3 relics to combo is what creates the "YESSS" moment.

#### Relic Philosophy
- Individual relics are good but not game-breaking
- 2-3 specific relics combined create exponential power spikes
- You're NEVER guaranteed to become broken — it requires knowledge + luck
- Some runs you find the combo. Most you don't. That's the gamble.
- No Synergy Log. Players discover combos organically. Community shares knowledge (wikis, Discord).
- Knowledge IS meta-progression: knowing "if I see Burning Touch, I should look for Oil Slick" makes veteran players stronger without any stat increase

#### Relic Categories
- **Combat**: Direct damage/defense effects (Burning Touch, Chain Lightning)
- **Economy**: Gold/value modifiers (Merchant's Blessing, Golden Purse)
- **Luck**: LCK and drop quality boosters (Carrot of Fortune, Rabbit's Foot)
- **Survival**: Healing and protection (Vampiric Edge, Stone Skin)
- **Cursed**: Rare, dramatic. Huge upside, harsh downside (Demon Blade: +80% ATK, 5 damage/turn to wielder)

#### Cursed Relics
Rare and dramatic. Finding one is a big moment. The upside is HUGE but the curse is harsh.
- Appear infrequently in reward choices
- Cannot be removed once taken (commit to the curse)
- Some curses can be mitigated by other relics (creating deeper combo discovery)
- At higher Corruption, more cursed relics appear in the pool

#### Example Relics
- "Burning Touch" — Melee attacks apply Burn (2 dmg/turn, 3 turns)
- "Chain Lightning" — Lightning damage jumps to 1 adjacent enemy at 50%
- "Carrot of Fortune" — +5 LCK to all units
- "Glass Cannon" — +50% ATK, -30% DEF
- "Vampiric Edge" — Killing blows heal attacker 20% of damage dealt
- "Merchant's Blessing" — Recruited units are worth +25% more cash at end of run
- "Demon Blade" (Cursed) — +80% ATK, unit takes 5 damage per turn

#### Synergy Examples
- "Burning Touch" + "Oil Slick" = fire + terrain = double fire damage
- "Chain Lightning" + "Conductive Armor" = AoE stun chain
- "Vampiric Edge" + "Glass Cannon" = high risk, high sustain
- "Merchant's Blessing" + aggressive recruiting = investment build

### 4.8 Reward System

After each combat encounter, choose 1 of 3 random rewards:

#### Equipment (per-unit, 3 slots)
- **Weapon**: Base ATK/MAG, may grant bonus ability (class-restricted)
- **Armor**: Base DEF/RES, passive effect. Armor TYPE affects type interactions (plate vs leather vs cloth).
- **Accessory**: Special effect (ring of haste: +1 MOV, amulet of thorns: reflect 10% damage)

#### Consumables (3 inventory slots max)
- **Health Potion**: Heal 1 unit 50% HP
- **Teleport Stone**: Move 1 unit to any tile (next combat)
- **Carrot**: +LCK for the run (temporary consumable, large boost). Rabbitson special.
- **Rabbit's Foot**: +LCK for the run (persistent, smaller boost). Equipment slot.

### 4.9 Overworld / Branching Path Map

Slay the Spire-style branching map, themed per biome. Biome order is **random** each run.

**Node types**:
| Node | Description |
|---|---|
| **Combat** | Standard tactics encounter. Reward + gold + possible recruit after clearing. |
| **Elite** | Harder encounter, better rewards, guaranteed higher-tier recruit chance. |
| **Boss** | End-of-biome fight. Unique per biome. 3 phases. Must defeat to continue. |
| **Shop** | Rabbitson's shop. Buy/sell equipment, relics, consumables. Always random inventory. |
| **Rest** | Menu of small actions: heal (partial), upgrade equipment, train (+XP), reroll ability. Pick 2 of 4. |
| **Event** | Random narrative event. Rewards, recruits, dilemmas. 10-15 events for MVP. |
| **Mystery** | Unknown until entered. Could be any of the above. |

**Run structure**:
- Full deep run = 3 biomes
- Each biome = ~4-6 nodes before boss
- Player can EXIT after ANY biome boss (cash out with rewards)
- Deeper runs earn a reward multiplier (1.5x after Biome 2, 2.0x after Biome 3)
- Direct biome transitions (no mini-hub between biomes)

#### Hidden Paths

Two types of secret content:

1. **Secret Map Nodes**: Some nodes on the map have a hidden branch. Visible only with high party LCK or specific relics. Leads to harder encounters with exclusive rewards (unique relics, S-tier recruit chance).

2. **Boss Portals**: After beating a biome boss, a portal MIGHT appear (RNG, luck-influenced). Enter for a bonus gauntlet floor: 3 hard fights with great rewards before continuing.

### 4.10 Event System

Minimal for MVP: 10-15 events. Expandable post-launch.

Events are floor-specific, drawn from weighted pools. No repeats within a run.

**Event categories**:
| Category | Description |
|---|---|
| **Recruitment** | A unit offers to join. Accept = new party member. Decline = small gold or send to bench. |
| **Gamble** | Risk/reward choices. "Drink the strange potion?" → random stat boost or curse. |
| **Trade** | Exchange resources. HP for gold, gold for relics, sacrifice a relic for a better one. |
| **Lore** | Narrative moment. Learn about Rabbitson's backstory, dungeon history. Small buff. |
| **Shrine** | Powerful but costly. "Sacrifice 25% max HP permanently for +3 ATK for the run." |

**Design rule**: Every choice costs something. No "free pass" options.

### 4.11 Economy

#### In-Run Economy: Gold (Tight)

Gold is scarce. You can afford 1-2 items per shop visit. Every gold piece matters.

- Earned from: combat clears, bonus objectives, selling unwanted equipment to Rabbitson
- Spent at: Rabbitson's in-run shop, insurance deals, pre-combat loadout investments
- Does NOT persist between runs

**Rabbitson buys back** relics and equipment for gold. "I'll give you 40g for that rusty shield." Liquidate unwanted items for shop purchases.

#### End-of-Run Economy: Cash (from unit appraisal)

When you EXIT (win), Rabbitson appraises surviving units. Cash value = tier base + level bonus + milestones (see 4.2).

Cash goes to persistent hub wallet.

#### Meta-Currency: Ember

Earned every run (win or lose) based on: biomes cleared, bosses beaten, bonus objectives, units recruited.
- Winning earns significantly more than losing
- Deeper runs earn more Ember

#### Rabbitson's Insurance (Gambling Mechanic)

Insurance is not a fixed product. Rabbitson offers **random "deals"** before combat:
- "I'll insure your Caster for 40g. If she dies, I'll pay you 80g. Deal?"
- Rates vary: sometimes a steal, sometimes a ripoff
- Player evaluates: Is this fight dangerous? Is the rate good?
- Adds another gambling layer to every combat node

### 4.12 Rabbitson (The Shopkeeper)

A mysterious, unsettling rabbit-like merchant. Inscryption's Leshy meets a dark fantasy bazaar.

**Personality**: Polite but wrong. Something is OFF about this rabbit. His deals feel Faustian. He speaks in riddles, makes carrot puns, and his smile never reaches his eyes. Creepy-charming.

**Appears at**:
If you are an AI or Human, this needs to be refined. When does Rabbitosn appear. He should not be everywhere. It is not a given, that rabbitson gives insureances on every run.
- Every shop node (buy/sell)
- Before combat (insurance deals)
- End of run (unit appraisal)
- Base camp (pre-run shop, hub upgrades)
- When you have no bench units (gives free C-tiers — acts benevolent, feels suspicious)

**The Carrot-Luck System**:
- Carrots are consumables sold by Rabbitson and found in events
- Eating a carrot: +LCK for the run (boosts loot quality, recruit quality, hidden path discovery)
- Carrot-synergy relics exist (Golden Carrot, Merchant's Nose, etc.)
- Carrots do NOT boost CRIT (that's a separate stat)

**Lore thread**: If you are an AI or human, this needs to be refined. Why does a rabbit sell weapons in dark fantasy dungeons? Rabbitson hints at a deeper story. Lore events reveal fragments. The full truth is end-game content.

**True Final Boss**: At maximum Corruption, Rabbitson reveals his true nature and IS the final boss. The shopkeeper was the villain (or something more complex) all along.

### 4.13 Meta-Progression

**Three pillars** of meta-progression, all using Cash and/or Ember:

#### 1. Hub Upgrades (Ember, scaling costs)
- Expand bench slots (2 → 3 → 4 → 5 → 6)
- Improve Rabbitson's shop (more items per visit, higher tier items in pool)
- Improve recruit quality in runs (higher tier units appear more frequently)
- Unlock new event types
- Expand relic pool (more relics available in runs)

#### 2. Starting Loadout (Cash, per-run)
- Buy items/equipment before a run starts from Rabbitson's pre-run shop
- Loadout items are equipped to specific starting units
- When a unit is sold at run end, their loadout items are also consumed
- Shop inventory is procedurally random each time
- Includes: weapons, shields, rabbit feet (LCK boost), carrots, consumables

#### 3. Content Unlocks (Ember, milestone-gated)
- New biomes
- New enemy types
- New relic pools
- New unit class variants
- The game literally EXPANDS as you play (Isaac philosophy)

### 4.14 Corruption System (Difficulty + Content)

After first win, unlock Corruption levels (1-20). Each level adds a modifier AND occasionally unlocks new content.

**Modifier Examples**:
- C1: Enemies +10% HP
- C2: Shop prices +20%
- C3: 2 reward choices instead of 3
- C4: Elite enemies appear in standard combat nodes
- C5: New enemy types unlocked + enemies gain abilities
- C6: More hazard terrain
- C7: Start with 1 curse relic
- C10: New relic pool additions + boss extra phase
- C15: Secret biome accessible
- C20: Rabbitson true final boss fight. Maximum difficulty. Special cosmetic unlock.

Corruption levels are **toggleable** independently or cumulatively. Self-directed difficulty.

### 4.15 Bestiary

Persistent across runs. Knowledge IS meta-progression.

- First encounter with any enemy type: stats show as "???"
- After fighting that type once: base stats recorded permanently
- Entries include: enemy name, type, element, base stats, abilities observed, biome(s) found in
- Unlocking all entries in a biome could grant a small reward (Ember, cosmetic)

### 4.16 Save System

**One mode: Classic**
- Save between nodes only (on the overworld map)
- Save is deleted on load (suspend-save)
- No mid-combat saving
- No save scumming by design
- If you quit mid-combat, you resume at the start of that node

### 4.17 Unit Stories + Memorial

#### During a Run
- Recruited units have procedural names, backstories, and personality traits
- Key combat moments are logged: kills, near-deaths, boss encounters, milestone achievements
- Personality traits affect stats AND generate combat barks

#### End of Run
- **Survivors sold**: Cash value displayed with a brief run summary per unit
- **Fallen units**: Added to a Memorial wall at base camp. Name, class, how they died.
- **Notable recruits**: Units with boss kills, clutch survivals, or bonus objectives get special memorial entries

---

## 5. Biomes (Initial 3, Random Order)

Biome order is randomized each run. Players cannot predict which biome comes next.

### Biome 1: The Crypt
- **Terrain**: Stone, pillars (LoS blockers), coffins (cover), darkness
- **Enemies**: Skeletons (Melee/Dark), Wraiths (Magic/Dark), Bone Archers (Ranged/Dark)
- **Boss**: The Lich King — summons adds, AoE dark magic, 3 phases
- **Recruitable**: Undead Knight (Vanguard/Dark, B-tier), Spirit Healer (Caster/Dark, A-tier)
- **Mood**: Darkest Dungeon meets LIMBO

### Biome 2: The Depths
- **Terrain**: Water (abundant), coral (cover), whirlpools (pull effect), sand, submerged ruins
- **Enemies**: Sea Serpents (Melee/Water), Sirens (Magic/Water), Harpoon Hunters (Ranged/Water)
- **Boss**: The Leviathan — tidal waves, high HP, spawns adds from water tiles
- **Recruitable**: Sea Spirit (Caster/Water, A-tier), Coral Golem (Vanguard/Water, B-tier)
- **Mood**: Mysterious, deep, bioluminescent

### Biome 3: The Ashlands
- **Terrain**: Lava, scorched earth, obsidian pillars, ash clouds (vision block)
- **Enemies**: Fire Golems (Melee/Fire), Ember Mages (Magic/Fire), Ash Snipers (Ranged/Fire)
- **Boss**: The Infernal — creates lava dynamically, buffs fire enemies, eruption phases
- **Recruitable**: Magma Elemental (Vanguard/Fire, S-tier!), Phoenix Scout (Scout/Fire, B-tier)
- **Mood**: Apocalyptic, red/orange silhouettes against gray

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
- **Turns**: Team-based alternating (no telegraphing)
- **Buffs**: ModiBuff or EnhancedStat addon for modifier stacking
- **Proc Gen**: Template-based arenas + procedural enemy/terrain placement
- **Overworld**: Node graph (Slay the Spire style)
- **Combat FSM**: Idle → Deploy → SelectUnit → SelectAction → SelectTarget → Execute → EnemyPhase → CheckWinLose

### Godot Addons to Evaluate
- [ModiBuff](https://godotengine.org/asset-library/asset/2166) — Buff/debuff stacking
- [EnhancedStat](https://github.com/Zennyth/EnhancedStat) — Stat modifiers
- [Godot Gameplay Systems](https://godotengine.org/asset-library/asset/932) — Attributes, abilities, equipment

---

## 7. Comparable Games Matrix

| Game | What Rabbitson Takes | What Rabbitson Adds |
|---|---|---|
| **Fire Emblem** | Grid tactics, weapon types, growth rates, unit permadeath | Roguelike loop, relic synergies, recruit-as-currency, no permanent units |
| **Binding of Isaac** | 100+ items, combo discovery, continue-deeper structure, community knowledge | Grid tactics, squad management, type system |
| **Slay the Spire** | Branching map, relic system, tight economy, run structure | Multi-unit tactics, recruit economy, deployment |
| **Darkest Dungeon** | Dark tone, party management, expedition structure | Grid positioning, relic combos, type matchups |
| **Hades** | Dark-with-levity tone, meta-progression, Corruption (heat) system | Tactics combat, party management, recruit economy |
| **LIMBO** | Art style (silhouettes, atmosphere, monochrome) | Everything else (tactics, roguelike, RPG systems) |

**Unique value**: The ONLY game combining grid tactics + roguelike runs + full-temporary warband + recruit-as-currency economy + 100+ relic synergies + logical type system + Limbo-style art.

---

## 8. MVP Scope (v0.1) — Full Vertical Slice

A complete vertical slice proving the entire gameplay loop:

### Core Systems
- [ ] Grid combat with deployment phase
- [ ] 4 archetypes (Vanguard, Marksman, Caster, Scout) — C and B tier only for MVP
- [ ] Turn system (player phase → enemy phase, no telegraphing)
- [ ] Moderate RNG damage (hit rates, dodge, crit)
- [ ] Basic type system (4 elements: Fire, Water, Nature, Dark)
- [ ] Weapon/armor type interactions (basic version)
- [ ] Unit leveling with XP from kills
- [ ] Level-up ability choices
- [ ] Stat system (HP, ATK, MAG, DEF, RES, SPD, MOV, LCK, CRIT)
- [ ] 3 combat objectives (Rout, Survive, Boss)
- [ ] Bonus objectives

### Map & Structure
- [ ] Branching path map (1 biome: The Crypt)
- [ ] Node types: Combat, Shop, Rest, Event, Elite, Boss
- [ ] 5-6 nodes before boss
- [ ] Exit gate after boss (end run)

### Economy
- [ ] Gold (in-run currency, tight economy)
- [ ] Cash (end-of-run from unit appraisal)
- [ ] Ember (meta-currency from progress)
- [ ] Recruit appraisal with cash value (tier + level + milestones)

### Rabbitson
- [ ] Shop node (buy/sell, always random inventory)
- [ ] Insurance deals (random gambling rates before combat)
- [ ] End-of-run appraisal
- [ ] Buyback mechanic (sell items/relics for gold)
- [ ] Basic dialogue and personality

### Unit System
- [ ] Recruitment mid-run (find recruits after combat/events)
- [ ] Bench system (limited slots, one-use)
- [ ] Rabbitson safety net (free C-tiers when bench empty)
- [ ] Personality traits (2-3 traits for MVP)
- [ ] Combat barks (5-10 lines per archetype)
- [ ] Permadeath + equipment loss on death
- [ ] S-tier decline → drops legendary item

### Items & Relics
- [ ] 10 equipment pieces (weapons, armor, accessories)
- [ ] 15-20 relics (including 2-3 cursed, 3-4 intended combos)
- [ ] 5 consumables (health potion, teleport stone, carrot, rabbit's foot, type shift crystal)

### Other Systems
- [ ] Rest nodes (menu: heal, upgrade, train, reroll — pick 2 of 4)
- [ ] 5-8 events
- [ ] Basic terrain (plains, forest, ruins, water, lava)
- [ ] Deployment zone (shape varies by map)
- [ ] Save between nodes (suspend-save)
- [ ] Memorial wall (basic: name, class, cause of death)
- [ ] Bestiary (persistent across runs)
- [ ] Basic hub (bench view, cash/ember wallet, pre-run shop, start run)

### NOT in MVP
- Hidden paths / boss portals
- Fog of war modifier
- Biomes 2 and 3
- Corruption system
- Hub upgrades
- Content unlocks
- Rabbitson true final boss
- Full 100+ relic set (15-20 for MVP)
- S-tier unit variants
- Full personality trait + bark library
- God's Hand auto-battle item
- Additional elements (Lightning, Earth, Ice, Light)
- Extended animation sets

---

## 9. Open Questions (Resolve Before Implementation)

### Design
- [ ] Exact type interaction matrix (damage types × armor types) — needs a detailed table
- [ ] Specific archetype tier names (working names in spec, need final names)
- [ ] Full ability list per archetype per tier
- [ ] Relic design: systematic combo rules vs hand-crafted combos only?
- [ ] Enemy AI behavior patterns (aggressive, defensive, support, flanking)
- [ ] How exactly do boss phases transition? (HP thresholds, scripted events?)
- [ ] Specific personality trait list and stat effects
- [ ] Combat bark writing and tone guidelines
- [ ] How does the "continue deeper" exit/continue UI look?
- [ ] What exactly does the pre-run shop offer? Fixed categories or pure random?

### Art
- [ ] Prototype Limbo-style top-down readability (can you distinguish 6 units on a grid?)
- [ ] Train custom LoRA on reference silhouettes
- [ ] Test AI sprite sheet generation consistency
- [ ] Define the exact gray-scale palette and lighting rules
- [ ] Determine sprite resolution (the "tile size" question translates differently for silhouettes)

### Technical
- [ ] Proc gen approach: WFC, BSP, or template-based?
- [ ] How to handle the suspend-save technically (serialization, state management)
- [ ] AI art pipeline tooling (set up Stable Diffusion + ControlNet or PixelLab workflow)
- [ ] Performance targets for grid rendering with fog/lighting effects

---

## 10. Future Considerations (Post-MVP)

These are shelved ideas, not commitments:

- [ ] **God's Hand**: Rare relic enabling AI auto-battle with stat buff. Requires good combat AI.
- [ ] **Additional Elements**: Lightning, Earth, Ice, Light (expand from 4 to 8)
- [ ] **Additional Biomes**: Beyond the initial 3
- [ ] **Additional Archetypes**: 5th archetype? Hybrid classes?
- [ ] **Fog of War Expansion**: More frequent, biome-specific fog rules
- [ ] **Board Manipulation**: Push/pull/terrain creation (currently cut for simplicity)
- [ ] **More Objective Types**: Escort, Seize, Break, Timed Rout, Puzzle Kill
- [ ] **Inter-Unit Bonds**: Support system (FE-style relationships between units)
- [ ] **Recruit Adoption**: Pay to make a recruit permanent (currently decided against, but revisitable)
- [ ] **Difficulty Modes**: Casual/Story mode with easier saves (currently one mode only)
- [ ] **Shareable Seeds**: Run seeds for community challenges
- [ ] **Cosmetic Unlocks**: Skins, alternate silhouette styles, palette swaps

---

## 11. Design Decisions Log

All major decisions made during the v2 design session, for reference:

| Decision | Choice | Rationale |
|---|---|---|
| Permanent units | **No** — all units temporary | More roguelike, more tension, more replayable |
| Tier system | Tier IS class variant (C/B/A/S) | Simpler than tier + rarity. Class name tells you quality. |
| Run length | Variable: exit after any boss | Isaac-style "continue deeper." Player controls commitment. |
| RNG level | Moderate (FE-style) | Hit rates + dodge + crit. Not fixed damage, not chaos. |
| Enemy telegraphing | **None** | FE-style: inspect enemies, read the battlefield. Not ITB puzzles. |
| Board manipulation | **No** — static terrain | Simplifies combat. Focus on movement + type matchups. |
| Fog of war | Event modifier only (~20%) | Keeps it surprising without making it the default. |
| Relic count target | 100+ at launch | Deep combo space. Isaac-scale discovery. |
| Synergy log | **No** | Organic community discovery. No hand-holding. |
| Carrots | Boost LCK (loot quality), NOT crit | Crit is separate stat. Carrots are treasure-hunting consumables. |
| Party LCK | Average of all units | Adding low-LCK units dilutes luck. Composition trade-off. |
| Insurance | Rabbitson's random gambling deals | Varying rates, per-combat. Another gambling layer. |
| Cursed items | Rare and dramatic | Big moment when found. Huge upside, harsh downside. |
| Sacrifice/sell | Shop buyback to Rabbitson | Liquidate unwanted items for gold. |
| Seeds | None (pure random) | Every run unique. No optimal seed meta-gaming. |
| Biome order | Random | Forces adaptation. No two runs feel the same. |
| Bench rules | Limited slots (2→6), one-use, S-tier excluded | Prevents hoarding. Bench is curated, not infinite. |
| Art style | LIMBO-inspired silhouettes, AI-generated | Distinctive, AI-feasible, matches dark tone. |
| Tone | Dark with levity (Hades) | Gothic world, humor exists, death is meaningful not depressing. |
| Rabbitson | Unsettling merchant (Inscryption vibes) | Polite but wrong. Creepy-charming. True final boss at max Corruption. |
| Multiplayer | Never | Solo experience, period. |
| Difficulty | One mode (Classic) | Save between nodes, suspend-save. Corruption for scaling. |
| MVP scope | Full vertical slice | Proves entire loop: combat, map, shop, bench, events, hub. |
| Fun cores | Combat (Raphael) + Relic combos (friend) | Both must be excellent. Combat is the foundation, combos are the hook. |
| Gold economy | Tight | 1-2 items per shop visit. Every gold piece matters. |
| Death equipment | Lost with unit | Makes death more punishing. Protect equipped units. |
| Combat healing | Multiple sources | Potions, abilities, lifesteal. HP is manageable but scarce. |
| Archetypes | 4 (Vanguard, Marksman, Caster, Scout) | Tight roster. Each with C/B/A/S variants = 16 types. |
| Elements | 4 at launch (Fire, Water, Nature, Dark) | Expandable. Simple to learn, room to grow. |
| Bestiary | Persistent across runs | Knowledge IS meta-progression. |
| Deployment | Zone shape varies by map | Adds pre-combat strategy. Blind entry creates surprises. |
| Rest nodes | Pick 2 of 4 actions | Heal, upgrade, train, reroll. Multiple small choices. |
| Boss design | Unique per biome, 3 phases | Predictable but thematic. Learnable patterns. |
| True final boss | Rabbitson himself | Max Corruption reveal. Shopkeeper was the villain all along. |
| Objectives | 3 types for launch | Rout, Survive, Boss. Add more post-launch. |
| Hidden paths | Map secrets + boss portals | Both luck-gated discovery and RNG post-boss portals. |
| Early exit rewards | Full rewards + deeper bonus multiplier | Carrot (bonus), not stick (penalty). Incentivize depth without punishing exit. |
| Auto-battle | Shelved for post-launch | Cool idea, needs good AI. Not MVP. |
