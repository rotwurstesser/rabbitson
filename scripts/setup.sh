#!/usr/bin/env bash
set -euo pipefail

# Rabbitson Developer Setup Script
# Run this once after cloning the repository.

echo "=== Rabbitson Developer Setup ==="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[X]${NC} $1"; }

# 1. Check Godot
echo "--- Checking prerequisites ---"
if command -v godot &>/dev/null; then
    ok "Godot found: $(godot --version 2>/dev/null || echo 'version unknown')"
else
    warn "Godot not found in PATH. Install from https://godotengine.org/download/"
    warn "On macOS: brew install --cask godot"
fi

# 2. Git LFS
if command -v git-lfs &>/dev/null || git lfs version &>/dev/null 2>&1; then
    ok "Git LFS installed"
    git lfs install --local 2>/dev/null && ok "Git LFS initialized in repo"
else
    warn "Git LFS not installed. Installing..."
    if command -v brew &>/dev/null; then
        brew install git-lfs && git lfs install --local
        ok "Git LFS installed and initialized"
    else
        fail "Cannot install git-lfs automatically. Install manually: https://git-lfs.com/"
    fi
fi

# 3. Node.js (for MCP server)
if command -v node &>/dev/null; then
    ok "Node.js found: $(node --version)"
else
    warn "Node.js not installed. Required for MCP server."
    warn "Install: brew install node  OR  https://nodejs.org/"
fi

# 4. Build MCP server
echo ""
echo "--- Godot MCP Server ---"
if [ -d ".mcp/godot-mcp/server" ]; then
    if [ -d ".mcp/godot-mcp/server/node_modules" ]; then
        ok "MCP server dependencies already installed"
    else
        echo "  Installing MCP server dependencies..."
        (cd .mcp/godot-mcp/server && npm install 2>&1) && ok "MCP server dependencies installed"
    fi
    if [ -f ".mcp/godot-mcp/server/dist/index.js" ]; then
        ok "MCP server already built"
    else
        echo "  Building MCP server..."
        (cd .mcp/godot-mcp/server && npm run build 2>&1) && ok "MCP server built"
    fi
else
    fail "MCP server not found at .mcp/godot-mcp/server"
fi

# 5. Godot MCP plugin check
if [ -d "addons/godot_mcp" ]; then
    ok "Godot MCP plugin found in addons/"
    echo "  Enable it in Godot: Project > Project Settings > Plugins > Godot MCP"
else
    fail "Godot MCP plugin not found in addons/godot_mcp"
fi

# 6. Detect AI tool
echo ""
echo "--- AI Tool Setup ---"

# Claude Code
if command -v claude &>/dev/null; then
    ok "Claude Code detected"
    echo "  Project rules: .claude/CLAUDE.md (loaded automatically)"
    echo ""
    echo "  To install Godot skills, run outside of a Claude session:"
    echo "    npx ai-agent-skills install Randroids-Dojo/Godot-Claude-Skills --agent claude"
else
    warn "Claude Code not detected (install: https://claude.com/download)"
fi

# Google Antigravity
if command -v antigravity &>/dev/null || [ -d "$HOME/.antigravity" ]; then
    ok "Google Antigravity detected"
    echo "  Project rules: .antigravity/rules.md (loaded automatically)"
    echo "  MCP config: .antigravity/mcp.json (project-scoped, loaded automatically)"
else
    warn "Google Antigravity not detected (install: https://antigravityai.org/)"
fi

echo ""
echo "=== Setup complete ==="
echo "Open project.godot in Godot to start developing."
