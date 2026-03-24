# Ona Claude Dotfiles

Claude Code configuration for use across local macOS, Ona cloud environments, and HPC servers.

## What's Included

- **`.claude/settings.json`** — Claude Code model and plugin config
- **`.claude/CLAUDE.md`** — Global Claude instructions
- **`.claude/skills/process-papers/`** — Custom paper processing skill

## Setup

### Ona

1. Push this repo to GitHub (private recommended)
2. Go to **Ona dashboard** → **User Settings** → **Dotfiles**
3. Enter the repo URL and save
4. New environments will auto-configure on creation

### HPC / Manual

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Updating

1. Edit files in this repo, commit, and push
2. New Ona environments pick up changes automatically
3. On HPC or existing environments: `git pull && ./install.sh`

## Adding Skills

Drop a new skill directory into `.claude/skills/` from any machine, commit, and push. All environments get the union of all skills after pulling and re-running `install.sh`.

## Notes

- `install.sh` is idempotent — safe to run multiple times
- Do not put secrets in this repo — use Ona secrets management
- Edit `HPC_HOSTNAME_PATTERN` in `install.sh` to match your HPC cluster hostname
