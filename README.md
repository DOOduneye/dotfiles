# Dotfiles

Managed with [chezmoi](https://chezmoi.io).

## Quick Setup

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DOOduneye

# Install dependencies
brew install fish starship mise zoxide atuin fzf bat eza fd thefuck direnv tmux

# Install Nerd Font (for prompt icons)
brew install --cask font-jetbrains-mono-nerd-font
# Then set "JetBrainsMono Nerd Font" in your terminal preferences

# Set fish as default shell
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Reload
exec fish
```

## What's Included

| Tool | Purpose |
|------|---------|
| **fish** | Shell |
| **starship** | Prompt |
| **mise** | Version manager (node, python, etc.) |
| **tmux** | Terminal multiplexer |
| **zoxide** | Smart cd |
| **atuin** | Shell history |
| **fzf** | Fuzzy finder |
| **bat** | Better cat |
| **eza** | Better ls |

## Key Bindings

### tmux (prefix: `Ctrl+a`)

| Binding | Action |
|---------|--------|
| `prefix + f` | Fuzzy find projects (sessionizer) |
| `prefix + s` | Session tree |
| `prefix + (` / `)` | Previous/next session |
| `prefix + \|` | Split vertical |
| `prefix + -` | Split horizontal |
| `prefix + r` | Reload config |
| `Ctrl+h/j/k/l` | Navigate panes |

### Fish Aliases

| Alias | Command |
|-------|---------|
| `gs` | git status |
| `gp` | git push |
| `gco` | git checkout |
| `gm` | git checkout main |
| `gmp` | git checkout main && git pull |
| `ls` | eza -alh |
| `cat` | bat |
| `cd` | zoxide |

## Machine-Specific Config

Create these files locally (not tracked):

- `~/.config/fish/conf.d/work.fish` - Work aliases
- `~/.config/tmux-sessionizer/dirs` - Project directories to scan

## Updating

```bash
chezmoi update  # Pull and apply latest
```
