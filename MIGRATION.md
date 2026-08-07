# Migrating to a New Mac

An ordered checklist. Each step has a command and a way to tell it worked.
`SETUP.md` explains why any of it is the way it is.

Read the whole of part 1 before starting — some of it can only be done while you
still have the old machine.

---

## Part 1 — On the machine you are leaving

### 1.1 Make the repository match the machine

```sh
chezmoi status
```

Anything listed means the repository and this machine disagree. Go through it
file by file and decide which side is right, then make them agree:

```sh
chezmoi diff ~/.config/some/file    # look at the difference
chezmoi add ~/.config/some/file     # the machine is right — pull it in
chezmoi apply ~/.config/some/file   # the repository is right — push it out
```

The direction matters more than it looks. Anything left only on this machine is
lost when you hand it back, and anything stale in the repository gets faithfully
reproduced on the new one.

Then commit and push, because the new machine clones from GitHub and not from
here:

```sh
chezmoi cd
git add -A && git commit -m "Sync before migration" && git push
exit
```

### 1.2 Copy out what chezmoi deliberately does not track

These are machine-local by design, so nothing will carry them for you. Look at
each and decide whether it is worth recreating:

```sh
cat ~/.config/fish/conf.d/*.fish            # work aliases
cat ~/.config/tmux-sessionizer/dirs         # project directories tmux scans
```

Most of it will be specific to the employer you are leaving and not worth
bringing. Anything that is worth bringing should be retyped on the new machine
rather than copied, so that secrets do not travel with it.

`PATH` entries added interactively with `fish_add_path` also stay behind — they
live in `~/.config/fish/fish_variables`, not in `config.fish`. That is fine;
they are debris from individual projects. If something there turns out to matter,
it belongs in `config.fish` where it is tracked.

### 1.3 Note what needs revoking later

Write down which SSH key on <https://github.com/settings/keys> belongs to this
machine. You revoke it in step 3.4, after the new machine is confirmed working —
not before, or you lock yourself out of the fallback.

```sh
ssh-keygen -lf ~/.ssh/id_ed25519.pub    # fingerprint, to identify it on GitHub
```

Do not copy the private key. The new machine gets its own.

### 1.4 Things that simply do not transfer

Named here so that you notice their absence deliberately rather than halfway
through a task:

```
Shell history          atuin sync is not configured. Starting clean is the
                       intended behaviour — see SETUP.md
gh / AWS / gcloud      per-employer credentials, re-authenticated not copied
kubectl contexts       same
INTERN_MCP_BEARER_TOKEN  and anything like it. Employer-scoped, dies here
Local databases        anything in postgres on this machine
Uncommitted work       check every repository for unpushed branches and
                       stashes before you hand the laptop over
```

---

## Part 2 — On the new machine

### 2.1 Command line tools and Homebrew

```sh
xcode-select --install
```

Wait for the GUI installer to finish, then:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

The installer prints a `PATH` snippet at the end. Run the `eval` line it gives
you, for this shell only:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

You are still in zsh at this point, and `/etc/paths` does not include
`/opt/homebrew/bin`, so without this `brew` is not found for the next two steps.
Once fish is the login shell in step 2.4 this stops mattering — `config.fish`
puts Homebrew on `PATH` itself, and there is no `~/.zprofile` in this setup to
do it for zsh. Do not add the snippet to a shell config; it is needed exactly
once.

Verify:

```sh
xcode-select -p          # expect /Library/Developer/CommandLineTools
brew --version
```

If Homebrew is blocked by IT, stop here and read the layer 2 note in `SETUP.md` —
mise can replace it, but the Brewfile cannot.

### 2.2 Dotfiles

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DOOduneye
```

It asks a short set of questions, and the answers select which applications the
Brewfile installs. They are stored, so this is asked once per machine.

```
Machine type (work or personal) [work]:
Install AI tools (Claude, ChatGPT, Codex)? [yes]:
Install Slack and Zoom? [yes]:
Install Spotify? [yes]:
Install Ollama (say no if preinstalled)? [no]:
Install Bitwarden? [no]:
```

Before answering, look at what IT has already installed. Anything already in
`/Applications` should get a no, because `brew install --cask` fails rather than
adopting an app that is already there.

```sh
ls /Applications
```

Then confirm:

```sh
chezmoi status                        # expect no output
cat ~/.config/chezmoi/chezmoi.toml    # confirm the answers were recorded
```

To change an answer later, edit that file directly — the Brewfile re-renders on
the next `chezmoi apply`.

### 2.3 Packages

```sh
brew bundle --global install
```

This installs the CLI tools and every GUI application in one pass, including
Ghostty, Zed, Obsidian, Claude, ChatGPT, Codex, Raycast, Chrome, Spotify, Hidden
Bar, AppCleaner, and the JetBrains Mono Nerd Font. It takes a while.

```sh
brew bundle --global check    # expect "The Brewfile's dependencies are satisfied"
```

### 2.4 Shell

```sh
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

Open a new terminal window — `chsh` does not affect the current one.

```sh
echo $SHELL              # expect /opt/homebrew/bin/fish
which starship mise direnv atuin zoxide
```

### 2.5 Terminal

Launch Ghostty once, then delete the template config it creates so there is only
one config file:

```sh
rm -f ~/Library/Application\ Support/com.mitchellh.ghostty/config
ghostty +validate-config                 # expect exit 0 and no output
ghostty +show-config | grep -E "theme|font-size"
```

If the font renders without ligatures or the prompt shows boxes instead of a git
branch glyph, the Nerd Font did not install. `ghostty +list-fonts | grep JetBrains`
should report `JetBrainsMono Nerd Font Mono`.

In Ghostty, start tmux and install its plugins with `prefix + I` (`Ctrl-a`, then
capital I). The plugin repositories themselves are already cloned by chezmoi.

### 2.6 SSH and GitHub

```sh
ssh-keygen -t ed25519 -C "davidoduneye1@gmail.com"
pbcopy < ~/.ssh/id_ed25519.pub
```

Add it at <https://github.com/settings/keys>, then:

```sh
ssh -T git@github.com    # expect "Hi DOOduneye! You've successfully authenticated"
```

Then authenticate the CLI, choosing SSH as the git protocol:

```sh
gh auth login
gh auth status
```

Confirm git picked up the managed config:

```sh
git config --global user.email          # expect davidoduneye1@gmail.com
git config --global core.excludesfile   # expect ~/.gitignore_global
```

If the new employer's GitHub organisation requires commits to use a
company-domain email address, add a directory-scoped override rather than
changing the global — `SETUP.md` covers the reasoning, and the mechanism is an
`[includeIf "gitdir:~/work/"]` section pointing at a second config file.

### 2.7 nvim

Launch it once and let it finish:

```sh
nvim
```

lazy.nvim installs plugins and Mason installs language servers. Expect a minute
of activity and some transient errors while that runs. Quit and reopen, then
`:checkhealth` to confirm.

### 2.8 Claude Code

`CLAUDE.md`, a baseline `settings.json`, and `mcp.json` are already in place from
`chezmoi apply`. Sign in, then confirm the plugins installed:

```sh
claude
```

The permission allowlist starts deliberately small, so expect more prompting
than you are used to for the first week. That is the point — the previous
machine's list had grown to 199 entries, most of them specific to one employer.

If you use the `qmd` MCP server, it needs its npm package, which is not in the
Brewfile:

```sh
npm install -g @tobilu/qmd
```

### 2.9 macOS settings

```sh
macos-defaults
```

Then log out and back in, because the keyboard settings are read by each
application when it launches.

```sh
defaults read -g KeyRepeat                  # expect 1
defaults read -g ApplePressAndHoldEnabled   # expect 0
```

Then the by-hand list in `SETUP.md` — trackpad first. The one to get right is
Secondary click set to two fingers rather than "Click bottom right corner".

### 2.10 Applications

Each of these needs a sign-in or a manual pass. The full detail of what does and
does not carry over is in `SETUP.md`; this is the checklist:

```
[ ] Zed          sign in. Settings and keymap already applied by chezmoi
[ ] Obsidian     open the vault folder. Re-enable community plugins
[ ] Raycast      sign in. Without Raycast Pro, reconfigure hotkeys and
                 snippets by hand. Set the hotkey before anything else
[ ] Claude       sign in
[ ] ChatGPT      sign in
[ ] Codex        sign in, then re-add model, model_reasoning_effort,
                 approvals_reviewer and any custom MCP servers
[ ] Slack        sign in per workspace
[ ] Chrome       sign in, let the profile sync
[ ] Spotify      sign in
[ ] Zoom         sign in
[ ] Hidden Bar   arrange the menu bar
[ ] PaceBar      install from the App Store
```

Work-managed software — SentinelOne, Rippling, or the equivalent — is installed
by IT and is not in the Brewfile.

### 2.11 Machine-local configuration

Recreate what you decided to keep from step 1.2:

```sh
$EDITOR ~/.config/fish/conf.d/work.fish
mkdir -p ~/.config/tmux-sessionizer && $EDITOR ~/.config/tmux-sessionizer/dirs
```

Secrets go in a project `.envrc` rather than here. `direnv` is installed and
hooked into fish already:

```sh
cd ~/some-project
echo 'export SOME_TOKEN="..."' > .envrc
direnv allow
```

---

## Part 3 — Closing out

### 3.1 Confirm the new machine works

Give it a few days of real use before doing anything irreversible.

### 3.2 Check for unpushed work

On the old machine, go through every repository for unpushed branches and
stashes.

### 3.3 Fix anything that drifted during setup

If you changed configuration by hand while getting the new machine working, it
lives only on that machine until you pull it in:

```sh
chezmoi status
chezmoi add <whatever you changed>
chezmoi cd && git add -A && git commit -m "..." && git push && exit
```

### 3.4 Revoke the old key

Remove the old machine's SSH key at <https://github.com/settings/keys>, using
the fingerprint from step 1.3. Sign out of anything on the old machine that
holds a session.
