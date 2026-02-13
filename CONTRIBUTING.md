# Contributing to Rabbitson

## Quick Start

```bash
git clone https://github.com/rotwurstesser/rabbitson.git
cd rabbitson
./scripts/setup.sh
```

The setup script checks and installs prerequisites automatically.

## Prerequisites

| Tool | Required | Install |
|---|---|---|
| [Godot 4.4+](https://godotengine.org/download/) | Yes | `brew install --cask godot` or download |
| [Git LFS](https://git-lfs.com/) | Yes | `brew install git-lfs` |
| [uv](https://docs.astral.sh/uv/) | For MCP | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

## AI Tool Setup

We use AI coding assistants. Both are configured in the repo.

### Claude Code

**Rules**: `.claude/CLAUDE.md` (loaded automatically when you open the project with Claude Code)

**Skills** (run outside a Claude session):
```bash
npx ai-agent-skills install Randroids-Dojo/Godot-Claude-Skills --agent claude
```

**GDAI MCP** (after enabling the Godot plugin):
```bash
claude mcp add gdai-mcp uv run <path-from-gdai-tab-in-godot>
```

### Google Antigravity

**Rules**: `.antigravity/rules.md` (loaded automatically)

**GDAI MCP**: Paste the JSON config from Godot's GDAI MCP tab into Antigravity's MCP settings panel.

### GDAI MCP Server (shared)

The [GDAI MCP Server](https://gdaimcp.com/) lets AI tools interact with the Godot editor directly — create scenes, edit scripts, read errors, run the project.

1. Download the plugin from [gdaimcp.com/docs/installation](https://gdaimcp.com/docs/installation)
2. Copy `addons/gdai-mcp-plugin-godot/` into this project's `addons/` folder
3. Open the project in Godot
4. Go to **Project > Project Settings > Plugins** and enable "GDAI MCP"
5. A "GDAI MCP" tab appears in the bottom panel — copy the config shown there
6. Add to your AI tool (see Claude Code or Antigravity sections above)

## Coding Standards

Read [docs/coding-standards.md](docs/coding-standards.md) before writing code. Key points:

- **Static typing** everywhere in GDScript
- **snake_case** for files, functions, variables
- **PascalCase** for class names
- **Signals + EventBus** for cross-system communication
- **Scripts next to their scenes**

## Project Structure

```
src/
├── autoload/       # Singletons (GameManager, EventBus)
├── entities/       # Player, enemies, NPCs
├── world/          # Dungeon generation, tiles, rooms
├── systems/        # Combat, inventory, loot, turns
└── ui/             # HUD, menus, game over
assets/             # Sprites, audio, fonts, shaders
test/               # GdUnit4 tests
addons/             # Godot plugins
docs/               # Documentation
scripts/            # Dev tooling scripts
```

## Git Workflow

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/my-feature
   ```
2. Make changes following the coding standards
3. Rename/move files **only in the Godot editor** (never from the filesystem)
4. Commit with a message explaining "why":
   ```bash
   git add <specific-files>
   git commit -m "Add turn system to support strategy gameplay"
   ```
5. Push and open a PR:
   ```bash
   git push -u origin feature/my-feature
   ```
6. Both devs review before merging

## Testing

Tests use [GdUnit4](https://mikeschulze.github.io/gdUnit4/). Place tests in `test/`.

```bash
# Run from Godot editor or CLI
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --path . --run-all
```

## Binary Assets

Binary files (images, audio, fonts, 3D models) are tracked with Git LFS via `.gitattributes`. This is automatic — just commit normally. If you add a new binary format, add it to `.gitattributes`.
