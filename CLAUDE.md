# Dotfiles

Personal dotfiles managed with GNU Stow. Each top-level directory is a stow package that symlinks to `~/`.

## Structure

| Directory | Symlinks To | Contains |
|-----------|-------------|----------|
| `claude/` | `~/.claude/` | Claude Code skills, agents, commands, settings |
| `git/` | `~/.gitconfig` | Git global config |
| `zsh/` | `~/.zshrc`, `~/.zprofile`, `~/.zshenv` | Zsh shell config |

## Key Locations

- **Skills**: `claude/.claude/skills/` - Custom Claude Code workflows
- **Agents**: `claude/.claude/agents/` - Specialized subagents (architecture-astronaut, code-simplifier, etc.)
- **Commands**: `claude/.claude/commands/` - Slash commands
- **Global CLAUDE.md**: `claude/.claude/CLAUDE.md` - Global instructions for all projects

## Workflow

1. Edit files in this repo (changes apply immediately via symlinks)
2. Commit and push to version control
3. Pull on other machines + `stow -R */` to sync
