# ~/.config/fish/config.fish

# === Environment ===
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx DIRENV_LOG_FORMAT ""  # silence direnv loading/unloading messages
set fish_greeting ""

# === PATH ===
fish_add_path /opt/homebrew/bin
fish_add_path ~/.local/bin

# === Tool Initialization ===
mise activate fish | source
zoxide init fish | source
atuin init fish | source
starship init fish | source
fzf --fish | source
thefuck --alias | source

# === Core Aliases ===
alias c="clear"
alias cat="bat"
alias find="fd"
alias ls="eza -alh"
alias cd="z"
alias vi="nvim"
alias restart="source ~/.config/fish/config.fish"

# === Git Aliases ===
alias gm="git checkout main"
alias gmp="git checkout main && git pull"
alias gg="git log --oneline --graph --all"
alias gd="git diff main | bat --language=diff"
alias gl="git log -1 HEAD"
alias gp="git push"
alias gs="git status"
alias gco="git checkout"
alias gu="git reset --soft HEAD~1"
abbr -a gcm "git commit -m"
abbr -a gunstage "git reset HEAD --"

# === tmux ===
alias t="tmux"
alias ta="tmux attach -t"
alias tls="tmux ls"
alias tn="tmux new -s"
alias tk="tmux kill-session -t"
abbr tat "tmux attach -t"
abbr tns "tmux new-session -s"

# === External Integrations ===
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
