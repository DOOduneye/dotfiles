# ~/.config/fish/config.fish

# Environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx PATH /opt/homebrew/opt/postgresql@15/bin $PATH

# Activate tools
mise activate fish | source
zoxide init fish | source
atuin init fish | source 
starship init fish | source
fzf --fish | source
thefuck --alias | source 

# Aliases (fish shell uses 'alias' too)
alias c="clear"
alias cat="bat"
alias find="fd"
alias ls="eza -alh"
alias cd="z"
alias vi="nvim"

alias gm="git checkout main"
alias gmp="git checkout main && git pull"
alias gg="git log --online --graph --all"
alias gd="git diff main | bat --language=diff"
alias gl="git log -1 HEAD"
alias gp="git push"
alias gs="git status"
alias gco="git checkout"
alias gu="git reset --soft HEAD~1"

abbr -a gcm "git commit -m"
abbr -a gunstage "git reset HEAD --"

# Disable greeting
set fish_greeting ""

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
