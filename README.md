# Rabbitson

A top-down strategy roguelike built with Godot 4 and GDScript.

Procedurally generated dungeons, permadeath, turn-based tactics. Every run is different, every death is permanent, every victory is earned.

## Tech Stack

- **Engine**: [Godot 4.4+](https://godotengine.org/)
- **Language**: GDScript (statically typed)
- **Architecture**: Signal-driven, autoload singletons, component systems

## Project Structure

```
rabbitson/
├── project.godot           # Godot project config
├── src/
│   ├── autoload/           # Singletons (GameManager, EventBus)
│   ├── entities/           # Player, enemies, NPCs
│   │   ├── player/
│   │   └── enemies/
│   ├── world/              # Dungeon generation, tiles, rooms
│   │   ├── dungeon/
│   │   └── tiles/
│   ├── systems/            # Combat, inventory, loot, turns
│   └── ui/                 # HUD, menus, game over
├── assets/
│   ├── sprites/
│   ├── audio/
│   ├── fonts/
│   └── shaders/
├── test/                   # GdUnit4 tests
├── addons/                 # Godot plugins
└── docs/
    └── coding-standards.md # Shared coding conventions
```

## Getting Started

### Prerequisites

- [Godot 4.4+](https://godotengine.org/download/) (standard build, not .NET)
- [Git](https://git-scm.com/) with [Git LFS](https://git-lfs.com/) installed

### Clone and Open

```bash
git clone https://github.com/rotwurstesser/rabbitson.git
cd rabbitson
git lfs install
```

Open `project.godot` in the Godot editor.

## AI-Assisted Development

Both developers use AI coding tools. The project includes configuration for both.

### Claude Code (Raphael)

AI rules live in `.claude/CLAUDE.md`. Install the Godot skills:

```bash
# From the project root — install skills globally
claude mcp add gdai-mcp -- npx -y @anthropic/gdai-mcp

# Or install skills for this project
# Copy skills to .claude/skills/ (see Skills section below)
```

**Recommended skills to install:**

| Skill | Install |
|---|---|
| Godot Claude Skills | `npx ai-agent-skills install Randroids-Dojo/Godot-Claude-Skills --agent claude` |
| GDScript Patterns | Search "Godot GDScript Patterns" on [mcpmarket.com](https://mcpmarket.com) |
| GDScript Validate | Search "GDScript Validate" on [mcpmarket.com](https://mcpmarket.com) |
| Godot 4 Code Gen | Search "Godot 4 Code Generation" on [mcpmarket.com](https://mcpmarket.com) |

### Google Antigravity (Friend)

AI rules live in `.antigravity/rules.md`. Antigravity reads this automatically.

### GDAI MCP Server (Both Tools)

The [GDAI MCP Server](https://gdaimcp.com/) lets AI tools control the Godot editor directly. It works with both Claude Code and Antigravity.

**Setup:**

1. Install `uv` (Python package manager):
   ```bash
   # macOS/Linux
   curl -LsSf https://astral.sh/uv/install.sh | sh

   # Windows
   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

2. Download the GDAI MCP plugin from [gdaimcp.com](https://gdaimcp.com/docs/installation)

3. Copy `addons/gdai-mcp-plugin-godot/` into this project's `addons/` folder

4. In Godot: **Project > Project Settings > Plugins** > enable "GDAI MCP"

5. Configure your AI tool:
   - **Claude Code**: `claude mcp add gdai-mcp uv run <path-from-gdai-tab>`
   - **Antigravity**: Paste the JSON config from the GDAI MCP tab in Godot into Antigravity's MCP settings

### Shared Standards

Both AI tools reference `docs/coding-standards.md` as the source of truth for GDScript conventions. Changes to coding standards should be made there, not in individual AI config files.

## Coding Standards

See [docs/coding-standards.md](docs/coding-standards.md) for full details. Key rules:

- Static typing everywhere
- `snake_case` files, functions, variables
- `PascalCase` class names
- Signals over direct references
- Scripts live next to their scenes

## Contributing

1. Create a feature branch from `main`
2. Follow the coding standards
3. Test with GdUnit4 if modifying game logic
4. Open a PR — both devs review

## License

TBD
