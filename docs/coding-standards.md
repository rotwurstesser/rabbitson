# Rabbitson Coding Standards

## GDScript Conventions

### Naming

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case.gd` | `dungeon_generator.gd` |
| Classes | `PascalCase` | `class_name DungeonGenerator` |
| Functions | `snake_case` | `func generate_floor()` |
| Variables | `snake_case` | `var current_floor: int` |
| Constants | `UPPER_SNAKE_CASE` | `const MAX_FLOOR: int = 20` |
| Signals | `snake_case` (past tense) | `signal player_moved` |
| Enums | `PascalCase` type, `UPPER_CASE` values | `enum State { IDLE, MOVING }` |
| Booleans | `is_` / `has_` / `can_` prefix | `var is_alive: bool = true` |

### Type Hints

Always use static typing. Enable typed warnings in Godot project settings.

```gdscript
# Correct
var health: int = 100
var position: Vector2i = Vector2i.ZERO
func take_damage(amount: int) -> void:

# Wrong
var health = 100
func take_damage(amount):
```

### Script Structure

Order sections in every script:

1. `class_name` (if needed)
2. `extends`
3. Doc comment (`##`)
4. Signals
5. Enums
6. Constants
7. `@export` variables
8. Public variables
9. Private variables (`_prefix`)
10. `@onready` variables
11. Built-in callbacks (`_ready`, `_process`, etc.)
12. Public methods
13. Private methods (`_prefix`)

### Signals Over Direct References

Prefer signals and the EventBus autoload for cross-system communication. Avoid direct node references between unrelated systems.

```gdscript
# Correct — decoupled via EventBus
EventBus.player_moved.emit(new_position)

# Wrong — tight coupling
get_node("/root/Main/UI/Minimap").update_position(new_position)
```

### Scene Organization

Each feature gets its own folder under `src/`:

```
src/
├── autoload/         # Singletons (GameManager, EventBus)
├── entities/         # Player, enemies, NPCs
│   ├── player/       # player.tscn + player.gd
│   └── enemies/      # Per enemy type
├── world/            # Map generation, tiles
│   ├── dungeon/      # Floor generation, room layouts
│   └── tiles/        # Tile definitions, tilesets
├── systems/          # Turn system, combat, inventory, loot
├── ui/               # HUD, menus, game over screen
└── utils/            # Shared helper functions
```

Keep scripts next to their scenes. One script per scene node.

### Resources

- Sprites go in `assets/sprites/`
- Audio goes in `assets/audio/`
- Fonts go in `assets/fonts/`
- Shaders go in `assets/shaders/`

Prefix asset names with their scene context when exclusive:
`player_idle.png`, `player_walk.png`

### Error Handling

Use `assert()` for debug-only invariants. Use `push_error()` / `push_warning()` for runtime issues.

```gdscript
assert(damage >= 0, "Damage cannot be negative")
if not target:
    push_error("Attack target is null")
    return
```

### Performance

- Use `Vector2i` for grid positions (roguelike grid is integer-based)
- Use object pooling for frequently spawned/despawned entities
- Avoid `get_node()` in `_process()` — cache with `@onready`
- Use `_physics_process()` only when physics are involved

### Git Workflow

- Rename/move files in the Godot editor only (never from filesystem directly)
- Commit before renaming files or folders
- Write commit messages that explain "why", not "what"
- Use feature branches, merge to `main` via PR
