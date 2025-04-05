function dotpush
    chezmoi apply
    set -l msg (string join " " $argv)

    set -l repo (chezmoi source-path)
    git -C $repo add -A

    if not git -C $repo diff --cached --quiet
        git -C $repo commit -m "$msg"
        git -C $repo push
        echo "✅ Dotfiles pushed: $msg"
    else
        echo "⚠️  No changes to commit."
    end
end

