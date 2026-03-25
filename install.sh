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

# --- Symlink skills into .ona/skills/ for Ona Agent ---
# Ona Agent reads skills from <project>/.ona/skills/, not ~/.claude/skills/.
# This makes dotfiles skills available in the Ona Agent chat.
PROJECT_DIR=""
if [[ "$ENV_NAME" == "ona" ]]; then
    # Find the project root: look for the workspace directory with a .git folder
    for candidate in /workspaces/*/; do
        if [[ -d "$candidate/.git" ]]; then
            PROJECT_DIR="$candidate"
            break
        fi
    done
fi

if [[ -n "$PROJECT_DIR" ]]; then
    mkdir -p "$PROJECT_DIR/.ona/skills"
    for skill_dir in "$DOTFILES_DIR"/.claude/skills/*/; do
        skill_name="$(basename "$skill_dir")"
        target="$PROJECT_DIR/.ona/skills/$skill_name"
        if [[ -d "$target" && ! -L "$target" ]]; then
            rm -rf "$target"
        fi
        ln -sfT "$skill_dir" "$target"
        echo "  Linked Ona skill: $skill_name → $target"
    done
    # Exclude .ona/ from git so it's never committed
    if [[ -d "$PROJECT_DIR/.git" ]]; then
        EXCLUDE_FILE="$PROJECT_DIR/.git/info/exclude"
        mkdir -p "$(dirname "$EXCLUDE_FILE")"
        if ! grep -qxF '.ona/' "$EXCLUDE_FILE" 2>/dev/null; then
            echo '.ona/' >> "$EXCLUDE_FILE"
            echo "  Added .ona/ to .git/info/exclude"
        fi
    fi
else
    echo "  Skipping Ona Agent skills (not in an Ona environment or no project found)"
fi

# --- Install Claude Code plugins ---
if command -v claude &>/dev/null; then
    echo "  Installing superpowers plugin..."
    claude plugins install superpowers@claude-plugins-official 2>/dev/null || true
    echo "  Superpowers plugin installed"
else
    echo "  claude CLI not found — skipping plugin install"
fi

# --- Summary ---
echo ""
echo "Done! Claude Code config installed for $ENV_NAME."
echo "  Config: ~/.claude/settings.json, ~/.claude/CLAUDE.md"
echo "  Skills: $(ls -1 ~/.claude/skills/ 2>/dev/null | tr '\n' ' ')"
