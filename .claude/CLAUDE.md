# Rabbitson — Claude Code Project Rules

## Project

Top-down strategy roguelike built with Godot 4 and GDScript.

## Tech Stack

- **Engine**: Godot 4.4+
- **Language**: GDScript (typed)
- **Architecture**: Signal-driven, autoload singletons, component systems

## Coding Standards

Follow `docs/coding-standards.md` — it is the shared source of truth for both AI tools.

Key rules:
- Always use static typing in GDScript
- Use `snake_case` for files, functions, variables
- Use `PascalCase` for class names
- Use `UPPER_SNAKE_CASE` for constants
- Prefix booleans with `is_`, `has_`, `can_`
- Prefer signals and EventBus over direct node references
- Keep scripts next to their scenes

## Project Structure

```
src/autoload/       — Singletons (GameManager, EventBus)
src/entities/       — Player, enemies, NPCs
src/world/          — Dungeon generation, tiles, rooms
src/systems/        — Combat, inventory, loot, turns
src/ui/             — HUD, menus, dialogs
assets/             — Sprites, audio, fonts, shaders
test/               — GdUnit4 tests
addons/             — Godot plugins (GDAI MCP, etc.)
```

## AI Workflow

- Read the scene tree and scripts before making changes
- Use the GDAI MCP server when available to interact with the Godot editor
- Run GdUnit4 tests after modifying game logic
- Never modify `.tscn` files by hand unless you understand the Godot scene format
- Prefer creating new nodes via GDScript over editing `.tscn` directly

## Git

- Raphael manages git operations
- Output commit messages and PR descriptions as text — do not run git commands
