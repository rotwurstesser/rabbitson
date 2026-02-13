# Rabbitson

A top-down strategy roguelike built with Godot 4 and GDScript.

Procedurally generated dungeons, permadeath, turn-based tactics. Every run is different, every death is permanent, every victory is earned.

## Tech Stack

- **Engine**: [Godot 4.6+](https://godotengine.org/)
- **Language**: GDScript (statically typed)
- **Architecture**: Signal-driven, autoload singletons, component systems

## Getting Started

### 1. Install prerequisites

| Tool                                            | Install                                                                      |
| ----------------------------------------------- | ---------------------------------------------------------------------------- |
| [Godot 4.6+](https://godotengine.org/download/) | `brew install --cask godot` or [download](https://godotengine.org/download/) |
| [Git LFS](https://git-lfs.com/)                 | `brew install git-lfs`                                                       |
| [Node.js](https://nodejs.org/)                  | `brew install node` (needed for MCP server)                                  |

### 2. Clone and set up

```bash
git clone https://github.com/rotwurstesser/rabbitson.git
cd rabbitson
./scripts/setup.sh
```

The setup script installs dependencies, builds the MCP server, and checks your environment.

### 3. Enable the Godot MCP plugin

1. Open `project.godot` in Godot
2. Go to **Project > Project Settings > Plugins**
3. Enable **"Godot MCP"**

### 4. Start developing

Open the project folder in your AI tool of choice (Claude Code or Antigravity) and start building.

## AI-Assisted Development

Both developers use AI coding tools. Everything is pre-configured in the repo.

### Google Antigravity

Open the project folder in Antigravity. It auto-loads:

- **`.antigravity/rules.md`** — GDScript coding standards and project rules
- **`.antigravity/rules.md`** — GDScript coding standards and project rules

### Godot MCP Setup

1. **Build the Server**:

   ```bash
   cd .mcp/godot-mcp/server
   npm install
   npm run build
   ```

2. **Configure Antigravity**:
   Add this to your global MCP config (e.g. `~/.gemini/antigravity/mcp_config.json`):
   ```json
   {
     "mcpServers": {
       "godot-mcp": {
         "command": "node",
         "args": [
           "/ABSOLUTE/PATH/TO/rabbitson/.mcp/godot-mcp/server/dist/index.js"
         ],
         "env": { "MCP_TRANSPORT": "stdio" }
       }
     }
   }
   ```

### Claude Code

Open the project folder with Claude Code. It auto-loads:

- **`.claude/CLAUDE.md`** — GDScript coding standards and project rules

Optional Godot skills (run outside a Claude session):

```bash
npx ai-agent-skills install Randroids-Dojo/Godot-Claude-Skills --agent claude
```

Optional MCP (connect Claude Code to the Godot editor):

```bash
claude mcp add godot-mcp node .mcp/godot-mcp/server/dist/index.js
```

### Godot MCP Server

The [Godot MCP Server](https://github.com/ee0pdt/Godot-MCP) is bundled in the repo at `.mcp/godot-mcp/`. It lets AI tools interact with the Godot editor directly — create scenes, edit scripts, read errors, manipulate the scene tree.

The MCP server is built automatically by `./scripts/setup.sh`. If you need to rebuild manually:

```bash
cd .mcp/godot-mcp/server
npm install
npm run build
```

### Shared Standards

Both AI tools reference [docs/coding-standards.md](docs/coding-standards.md) as the single source of truth. Edit standards there, not in individual AI config files.

## Project Structure

```
rabbitson/
├── project.godot           # Godot project config
├── src/
│   ├── autoload/           # Singletons (GameManager, EventBus)
│   ├── entities/           # Player, enemies, NPCs
│   ├── world/              # Dungeon generation, tiles, rooms
│   ├── systems/            # Combat, inventory, loot, turns
│   └── ui/                 # HUD, menus, game over
├── assets/                 # Sprites, audio, fonts, shaders
├── test/                   # GdUnit4 tests
├── addons/                 # Godot plugins (MCP included)
├── .mcp/                   # MCP server (bundled)
├── .claude/                # Claude Code config
├── .antigravity/           # Google Antigravity config
├── docs/                   # Coding standards
└── scripts/                # Dev tooling
```

## Coding Standards

See [docs/coding-standards.md](docs/coding-standards.md). Key rules:

- Static typing everywhere
- `snake_case` files, functions, variables
- `PascalCase` class names
- Signals over direct references
- Scripts live next to their scenes

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for full details.

1. Create a feature branch from `main`
2. Follow the coding standards
3. Test with GdUnit4 if modifying game logic
4. Open a PR — both devs review

## License

TBD
