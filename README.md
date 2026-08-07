# Dotfiles

macOS development environment, managed with [chezmoi](https://chezmoi.io).

- **[SETUP.md](SETUP.md)** — how the machine is put together and why
- **[MIGRATION.md](MIGRATION.md)** — ordered checklist for moving to a new Mac

## Quick setup

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DOOduneye
brew bundle --global install

echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

`chezmoi init` asks whether this is a work or a personal machine, then which
optional applications to install — so a machine where IT has already put Slack
or Ollama in `/Applications` does not fight Homebrew over them. Answers are
stored in `~/.config/chezmoi/chezmoi.toml` and asked once.

`MIGRATION.md` covers the rest — SSH keys, macOS settings, and per-application
sign-in.

## What's included

```
fish        shell
starship    prompt
tmux        multiplexer, prefix Ctrl-a
nvim        editor (AstroNvim), aliased to `vi`
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

Install layers are explained in [SETUP.md](SETUP.md#the-install-model): Homebrew
casks for applications, Homebrew formulae for machine-wide CLI tools, mise for
anything a project pins a version of.

## Key bindings

tmux, prefix `Ctrl-a`:

```
prefix + f        fuzzy find projects (sessionizer)
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

Not tracked here, by design. Create locally as needed:

```
~/.config/fish/conf.d/*.fish        work aliases, one-off PATH additions
~/.config/tmux-sessionizer/dirs     project directories to scan
<project>/.envrc                    secrets, loaded by direnv
```

Secrets belong in an `.envrc` or the keychain, never in `config.fish`. This
repository is public.

## Day to day

```sh
chezmoi status        what differs between this repo and the machine
chezmoi diff          the same, in detail
chezmoi add <path>    pull a file on this machine into the repo
chezmoi apply         write the repo's version out to this machine
chezmoi update        pull from GitHub and apply
chezmoi cd            shell into the source directory
```
