# Ona Claude Dotfiles Design Spec

## Summary

A dotfiles repo that ships Claude Code configuration (settings, instructions, and custom skills) to any environment — local macOS, Ona cloud environments, and HPC servers. Uses an idempotent `install.sh` script with environment detection and symlinks.

## Goals

- Claude Code config (model, plugins, instructions) available on every environment automatically
- Custom `/process-papers` skill available everywhere
- Idempotent install — safe to run multiple times
- Environment-aware — detects local macOS vs Ona (Linux) vs HPC (Linux, different hostname)
- Manual sync workflow — user pushes changes to repo, environments pick them up on next session

## Non-Goals

- Auto-sync hooks or auto-commit/push
- Shell config (.zshrc, .bashrc)
- Git config (.gitconfig)
- Editor or tmux config

## Repo Structure

```
dotfiles/
├── .claude/
│   ├── settings.json                    # Claude Code config (model, plugins)
│   ├── CLAUDE.md                        # Global Claude instructions
│   └── skills/
│       └── process-papers/
│           ├── SKILL.md                 # Skill definition
│           └── prompts/
│               ├── ingest-pdfs.md
│               ├── ingest-urls.md
│               ├── ingest-obsidian.md
│               ├── summarize-brief.md
│               ├── summarize-detailed.md
│               ├── synthesize-brief.md
│               ├── synthesize-detailed.md
│               ├── crosscheck.md
│               ├── output-template.md
│               ├── replication-plan.md
│               └── single-paper-analysis.md
├── install.sh                           # Idempotent setup script
├── README.md                            # Usage instructions
└── docs/
    └── superpowers/
        └── specs/
            └── (this file)
```

## install.sh Design

### Environment Detection

```
uname -s == "Darwin"  → local macOS
hostname matches HPC pattern → HPC server
else → Ona cloud environment
```

The script uses `uname -s` for OS detection and `hostname` for distinguishing HPC from Ona (both Linux). HPC hostname detection uses a configurable variable at the top of the script:

```bash
HPC_HOSTNAME_PATTERN="hpc*"  # User sets this to match their HPC hostname
```

The pattern is matched with a bash glob (`[[ $(hostname) == $HPC_HOSTNAME_PATTERN ]]`). The user should update this variable to match their HPC cluster's hostname convention.

### Operations

1. Resolve `DOTFILES_DIR` to the script's own directory
2. Detect environment (local / Ona / HPC) and print it
3. `mkdir -p ~/.claude/skills`
4. Symlink `settings.json` → `~/.claude/settings.json` (`ln -sf`)
5. Symlink `CLAUDE.md` → `~/.claude/CLAUDE.md` (`ln -sf`)
6. Symlink `skills/process-papers/` → `~/.claude/skills/process-papers` (use `ln -sfn` on macOS/BSD, `ln -sfT` on Linux)
7. Print summary of what was linked

### Error Handling

- Script uses `set -e` to exit on first error
- If a target path is a regular file (not a symlink), `ln -sf` will replace it — this is intentional, as the dotfiles repo is the source of truth
- Script exits 0 on success, non-zero on failure (compatible with Ona's automated invocation)

### Idempotency

- `mkdir -p` — no-op if directory exists
- `ln -sf` — overwrites existing symlinks or regular files safely
- Directory symlinks use platform-appropriate flags: `ln -sfn` on macOS (BSD), `ln -sfT` on Linux (GNU)
- No destructive operations beyond overwriting config files that the script manages

### Environment-Specific Behavior

Currently all environments get the same config. The detection is in place so future environment-specific logic (e.g., different settings.json for HPC) can be added without restructuring.

## Workflow

### Initial Setup

1. Populate the dotfiles repo with exactly the files listed in the Repo Structure section above (settings.json, CLAUDE.md, skills/process-papers/). Do not include other `~/.claude/` files (history, sessions, cache, etc.)
2. Create `install.sh` and ensure it is executable (`chmod +x install.sh`)
3. Push to GitHub (private repo recommended)
4. Configure Ona dashboard → User Settings → Dotfiles → repo URL. Ona clones the repo and runs `install.sh` (via `bash install.sh`) automatically when provisioning a **new** environment.
5. On HPC: `git clone <repo>` then `./install.sh`

### Updating Config

1. Edit files in the dotfiles repo (or edit `~/.claude/` and copy back)
2. Commit and push
3. **New** Ona environments automatically get the update. Existing live environments do NOT auto-update — to update an existing environment, re-run `install.sh` after pulling.
4. On HPC: `git pull && ./install.sh`

## Testing

- Run `install.sh` on macOS — verify symlinks created in `~/.claude/`
- Run `install.sh` twice — verify idempotent (no errors, same result)
- Verify `claude` CLI loads config from symlinked files
- Verify `/process-papers` skill is available after install

## Security Notes

- Repo should be **private** — settings.json may reveal plugin config
- No secrets (API keys, tokens) in dotfiles — use Ona secrets management
- `settings.json` currently contains no sensitive data — only: `"model"`, `"enabledPlugins"` (superpowers toggle), and `"skipDangerousModePermissionPrompt"`

## Out of Scope

- The `process-papers` skill files are included as-is from the user's existing `~/.claude/skills/` directory. Their content and behavior are not specified by this design — they are simply carried along by the dotfiles repo.
- `README.md` will contain basic usage instructions (clone, run install.sh, configure Ona). Its exact content is an implementation detail.
- Uninstall/rollback: not in scope. To undo, manually remove the symlinks (`rm ~/.claude/settings.json ~/.claude/CLAUDE.md; rm -rf ~/.claude/skills/process-papers`).
