if status is-interactive
    and not set -q TMUX
    tmux attach -t default || tmux new -s default
end
