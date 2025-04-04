# ~/.config/fish/config.fish

# Environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

set -gx PATH /opt/homebrew/bin $PATH  # Homebrew on Apple Silicon
set -gx PATH ~/.local/bin $PATH       # Common user scripts
mise activate fish | source

# zoxide
zoxide init fish | source

# atuin
# atuin init fish | source

# starship
starship init fish | source

# Aliases (fish shell uses 'alias' too)
alias cat="bat"
alias find="fd"
alias ls="eza -alh"
# alias cd="z"

# Abbreviations (expand-as-you-type)
abbr -a gco "git checkout"
abbr -a gs "git status"
abbr -a gcm "git commit -m"
abbr -a gl "git pull"
abbr -a gp "git push"

# Disable greeting
set fish_greeting ""

# Prompt for optional vi mode
# fish_vi_key_bindings

# 7. Misc: FZF keybindings (if installed)
# Add this only if you have FZF installed with keybinds
# [ -f ~/.fzf.fish ] && source ~/.fzf.fish
