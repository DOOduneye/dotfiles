# ~/.config/fish/config.fish

# Environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH ~/.local/bin $PATH

# Activate tools
mise activate fish | source
zoxide init fish | source
atuin init fish | source 
starship init fish | source
fzf --fish | source

# Aliases (fish shell uses 'alias' too)
alias cat="bat"
alias find="fd"
alias ls="eza -alh"
alias cd="z"
alias vi="nvim"

# Abbreviations (expand-as-you-type)
abbr -a gco "git checkout"
abbr -a gs "git status"
abbr -a gcm "git commit -m"
abbr -a gl "git pull"
abbr -a gp "git push"

# Disable greeting
set fish_greeting ""
