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

# 3. uv (for GDAI MCP)
if command -v uv &>/dev/null; then
    ok "uv installed: $(uv --version)"
else
    warn "uv not installed. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ok "uv installed"
fi

# 4. Detect AI tool
echo ""
echo "--- AI Tool Setup ---"

# Claude Code
if command -v claude &>/dev/null; then
    ok "Claude Code detected"
    echo "  Project rules: .claude/CLAUDE.md"
    echo ""
    echo "  To install Godot skills, run outside of a Claude session:"
    echo "    npx ai-agent-skills install Randroids-Dojo/Godot-Claude-Skills --agent claude"
    echo ""
    echo "  To add GDAI MCP (after enabling the Godot plugin):"
    echo "    claude mcp add gdai-mcp uv run <path-from-gdai-tab>"
else
    warn "Claude Code not detected (install: https://claude.com/download)"
fi

# Google Antigravity
if command -v antigravity &>/dev/null || [ -d "$HOME/.antigravity" ]; then
    ok "Google Antigravity detected"
    echo "  Project rules: .antigravity/rules.md (loaded automatically)"
    echo ""
    echo "  To add GDAI MCP:"
    echo "    Paste the JSON config from Godot's GDAI MCP tab into Antigravity's MCP settings"
else
    warn "Google Antigravity not detected (install: https://antigravityai.org/)"
fi

# 5. GDAI MCP plugin check
echo ""
echo "--- GDAI MCP Plugin ---"
if [ -d "addons/gdai-mcp-plugin-godot" ]; then
    ok "GDAI MCP plugin found in addons/"
    echo "  Enable it in Godot: Project > Project Settings > Plugins"
else
    warn "GDAI MCP plugin not found."
    echo "  Download from: https://gdaimcp.com/docs/installation"
    echo "  Copy addons/gdai-mcp-plugin-godot/ into this project's addons/ folder"
fi

echo ""
echo "=== Setup complete ==="
echo "Open project.godot in Godot to start developing."
