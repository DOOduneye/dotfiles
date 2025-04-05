# Terminal Configuration Overview

## Installed Toolchain

- **Shell Environment**: Fish shell (Fish)
- **Prompt Rendering**: Starship
- **Command History**: Atuin (with fuzzy search mapped to the up arrow key)
- **Fuzzy Selection Interface**: fzf, enabled via `fzf --fish | source`
- **Utility Aliases**: `bat`, `fd`, `eza -alh`
- **Command Abbreviations**: Git-specific shorthand (e.g., `gco`, `gs`, `gcm`, `gl`, `gp`)
- **Environment Management**: mise and zoxide

## Fish Shell Configuration (`~/.config/fish/config.fish`)

- Declaration of key environment variables and PATH extensions
- Initialization blocks for external tools (mise, starship, zoxide, etc.)
- Definition of command aliases and dynamic abbreviations
- Clean integration of `fzf` via `fzf --fish | source` to enable default keybindings

## Dotfile Orchestration

- Dotfiles are version-controlled using **chezmoi**
- Source files are maintained under `~/.local/share/chezmoi`
- Synchronization workflow: `chezmoi add`, `chezmoi diff`, `chezmoi apply`

### Adding New Configuration Files

1. Relocate or symlink the configuration file into its appropriate target directory
2. Execute: `chezmoi add <path>`
3. Optionally review staged changes via `chezmoi diff`
4. Apply updates consistently with `chezmoi apply` or use the dotpush function
