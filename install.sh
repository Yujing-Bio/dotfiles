#!/bin/bash
set -e

# ============================================================
# Ona Claude Dotfiles — install.sh
# Idempotent setup script for local macOS, Ona, and HPC
# ============================================================

# --- Configuration ---
# Set this to match your HPC cluster's hostname pattern (bash glob)
HPC_HOSTNAME_PATTERN="hpc*"

# --- Resolve script directory ---
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Detect environment ---
OS="$(uname -s)"
HOSTNAME="$(hostname)"

if [[ "$OS" == "Darwin" ]]; then
    ENV_NAME="local-macos"
elif [[ $HOSTNAME == $HPC_HOSTNAME_PATTERN ]]; then
    ENV_NAME="hpc"
else
    ENV_NAME="ona"
fi

echo "Environment detected: $ENV_NAME"
echo "Dotfiles source: $DOTFILES_DIR"

# --- Create target directories ---
mkdir -p ~/.claude/skills

# --- Symlink config files ---
ln -sf "$DOTFILES_DIR/.claude/settings.json" ~/.claude/settings.json
echo "  Linked: settings.json"

ln -sf "$DOTFILES_DIR/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
echo "  Linked: CLAUDE.md"

# --- Symlink skills (directory symlink — platform-aware) ---
for skill_dir in "$DOTFILES_DIR"/.claude/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    target=~/.claude/skills/"$skill_name"
    # If target is a real directory (not a symlink), remove it first
    if [[ -d "$target" && ! -L "$target" ]]; then
        rm -rf "$target"
    fi
    if [[ "$OS" == "Darwin" ]]; then
        ln -sfn "$skill_dir" "$target"
    else
        ln -sfT "$skill_dir" "$target"
    fi
    echo "  Linked skill: $skill_name"
done

# --- Summary ---
echo ""
echo "Done! Claude Code config installed for $ENV_NAME."
echo "  Config: ~/.claude/settings.json, ~/.claude/CLAUDE.md"
echo "  Skills: $(ls -1 ~/.claude/skills/ 2>/dev/null | tr '\n' ' ')"
