# Dotfiles

macOS development environment, managed with [chezmoi](https://chezmoi.io).

- **[SETUP.md](SETUP.md)** — how the machine is put together and why
- **[MIGRATION.md](MIGRATION.md)** — ordered checklist for moving to a new Mac

## Quick setup

```sh
# Apple's command line developer tools: git, a C compiler, system headers.
# Homebrew needs them. Opens a GUI installer — wait for it to finish.
xcode-select --install

# Install Homebrew. Asks for your password, because it creates /opt/homebrew.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Put brew on PATH for this shell only. You are still in zsh here.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Clone this repo and write every config into place. Asks the setup questions.
# The `--` splits the installer's arguments from chezmoi's.
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DOOduneye

# Install everything in ~/.Brewfile, which the step above just wrote.
# `--global` is what points brew at ~/.Brewfile rather than the current folder.
brew bundle --global install

# Register fish as an allowed login shell. `tee -a` appends to a root-owned
# file; `sudo echo >>` fails, because your shell does the redirect, not sudo.
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells

# Make it the login shell. Refuses shells missing from /etc/shells, hence the
# order. Applies to new windows only.
chsh -s /opt/homebrew/bin/fish
```

`chezmoi init` asks machine type and which optional apps to install, once, and
stores the answers in `~/.config/chezmoi/chezmoi.toml`.

## What's included

```
fish        shell
starship    prompt
tmux        multiplexer, prefix Ctrl-a
nvim        editor, aliased to `vi`. 12 plugins, no framework
vim         minimal no-plugin fallback config
mise        per-project runtime versions
zoxide      smart cd
atuin       shell history, fuzzy search on the up arrow
direnv      per-directory environment variables
fzf         fuzzy finder
bat / eza / fd / ripgrep      cat, ls, find, grep
gh / lazygit / difftastic     git tooling
ghostty     terminal
zed         second editor
```

Casks for apps, formulae for machine-wide CLI, mise for anything a project pins.
See [the install model](SETUP.md#the-install-model).

## Key bindings

tmux, prefix `Ctrl-a`:

```
prefix + s        session tree
prefix + ( / )    previous / next session
prefix + | / -    split vertical / horizontal
prefix + g        lazygit popup
prefix + r        reload config
prefix + I        install plugins
Ctrl + h/j/k/l    navigate panes
Ctrl + Space      zoom pane
```

fish aliases:

```
gs      git status                      ls      eza -alh
gp      git push                        cat     bat
gco     git checkout                    find    fd
gm      git checkout main               cd      z (zoxide)
gmp     git checkout main && git pull   vi      nvim
gd      git diff main | bat
gg      git log --oneline --graph --all
gcm     git commit -m   (abbreviation)
```

## Machine-specific config

Untracked by design. Create locally as needed:

```
~/.config/fish/conf.d/*.fish    work aliases, one-off PATH additions
<project>/.envrc                secrets, loaded by direnv
```

This repository is public. Secrets go in an `.envrc` or the keychain.

## chezmoi management

```sh
chezmoi status        what differs between this repo and the machine
chezmoi diff          the same, in detail
chezmoi add <path>    pull a file on this machine into the repo
chezmoi apply         write the repo's version out to this machine
chezmoi update        pull from GitHub and apply
chezmoi cd            shell into the source directory
```
