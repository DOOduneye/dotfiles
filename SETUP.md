# Mac Setup

How this machine is put together, and why each piece is where it is. If you are
setting up a new Mac, `MIGRATION.md` is the ordered checklist — this document is
the reasoning behind it, and the thing to read when a decision here stops making
sense and you want to know what it was protecting against.

---

## Bootstrap

Four commands on a fresh machine. Everything else in this document explains what
they do or covers what they cannot.

```sh
xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DOOduneye

brew bundle --global install
```

`chezmoi init` asks a short set of questions and stores the answers in
`~/.config/chezmoi/chezmoi.toml`. Templates in the repo branch on them, so one
repository produces an intentional machine rather than a fixed list plus a set
of things to remember to uninstall.

```
Machine type (work or personal) [work]:
Install AI tools (Claude, ChatGPT, Codex)? [yes]:
Install Slack and Zoom? [yes]:
Install Spotify? [yes]:
Install Ollama (say no if preinstalled)? [no]:
Install Bitwarden? [no]:
```

The machine-type answer sets the defaults for the ones below it — Ollama and
Bitwarden default to yes on a personal machine and no on a work one.

The application questions exist because of managed machines specifically. If IT
has already placed Slack or Ollama in `/Applications`, `brew install --cask`
fails with "It seems there is already an App at ...". `brew install --cask
--adopt` can take over an identical existing app, but `brew bundle` exposes no
way to pass that through, so answering no here is the clean path.

To change an answer later, edit `~/.config/chezmoi/chezmoi.toml` directly, or
delete it and re-run `chezmoi init`.

On Apple Silicon, Homebrew's installer prints a `PATH` snippet at the end. Run
its `eval` line once in the current shell so that `brew bundle` can be found —
you are still in zsh at that point, and `/etc/paths` does not include
`/opt/homebrew/bin`. Do not add it to a shell config: once fish is the login
shell, `config.fish` puts Homebrew on `PATH` itself.

---

## The install model

Three layers. Which layer something belongs to is decided by one question, not
by preference:

```
Layer 1 — GUI applications (.app bundles)      → Homebrew casks
          Ghostty, Zed, Obsidian, Claude, ChatGPT, Codex, Raycast,
          Chrome, Slack, Spotify, Hidden Bar, AppCleaner
          Test: does it appear in /Applications?

Layer 2 — machine-wide CLI, always at latest   → Homebrew formulae
          fish, tmux, git, gh, chezmoi, mise, starship, ripgrep,
          fzf, bat, eza, fd, zoxide, atuin, direnv, lazygit,
          difftastic, tree, xh, ffmpeg
          Test: would you ever want two versions at once? No.

Layer 3 — per-project runtimes                 → mise
          node, python, go, bun, postgres, terraform
          Test: does a repo you clone care which version this is? Yes.
```

The layer 3 test is the whole model. `ripgrep` at 14.1 versus 14.2 never breaks
a checkout, so it belongs to the machine and Homebrew owns it. But cloning one
repo that needs Node 20 next to another that needs Node 22 is a real conflict,
and resolving it is precisely what mise exists for — it reads a `.mise.toml` or
`.tool-versions` in the project directory and puts the correct binary first on
`PATH` while you are inside it.

This is why `postgres` is not in the Brewfile. Installing `postgresql@16`
machine-wide is a global decision made on behalf of whichever project happened to
need it first; the next project needing 15 then has to fight it. Declare it per
repository instead.

Almost every layer 2 tool is *also* available through mise (`gh` is
`aqua:cli/cli` in its registry, and so are atuin, bat, fd, fzf, ripgrep,
starship, zoxide and the rest). Resist it. What mise buys is version pinning,
which these tools do not need, and what it costs is shim resolution on every
command plus a second place to look when a binary goes missing. The one scenario
that flips this is a work machine where IT restricts Homebrew — check on day
one, and if so, mise is a complete fallback for layer 2.

### Global mise tools

`~/.config/mise/config.toml` holds only `neovim`, `uv`, and `pnpm`, all at
latest. These are package managers and an editor — tools you want everywhere,
with no project opinion about their version. If you catch yourself adding a
language runtime here, that is the signal it should have been a project
dependency.

---

## Shell

fish, with starship for the prompt. fish is not POSIX-compatible, which is
occasionally inconvenient and never a real problem — scripts declare their own
interpreter, and `bash -c '...'` still works when a README hands you something
POSIX.

Setting it as the login shell requires registering it first, because `chsh`
refuses any shell not listed in `/etc/shells`:

```sh
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

There is deliberately no `~/.zprofile` here. That file is zsh's login profile,
and once `chsh` has pointed at fish, nothing in normal use reads it — terminals
and `ssh` both start fish. A zsh started *from* fish inherits the environment
already, so `brew` is on `PATH` there regardless:

```sh
fish -l -c 'zsh -c "which brew"'    # /opt/homebrew/bin/brew
```

The one genuinely uncovered case is a fresh zsh login shell with nothing
inherited, which in practice means the bootstrap window on a new machine before
`chsh` has run. `/etc/paths` does not include `/opt/homebrew/bin`, so during
that window `brew` is not found. `MIGRATION.md` handles it with one explicit
`eval` rather than carrying a config file forever for a five-minute problem.

### PATH added interactively does not transfer

`fish_add_path` writes to fish's *universal* variables in
`~/.config/fish/fish_variables`, which is not tracked. Directories added that
way — keg-only Homebrew formulae, one-off SDKs — exist on one machine and
nowhere else, and they are gone after a migration.

That is the correct outcome. They are almost always debris from a single
project, and several will already point at things that are no longer installed.
Anything that genuinely should be permanent belongs in `config.fish`, where it
is tracked.

`config.fish` initialises tools in a deliberate order and then defines aliases.
The initialisation block is the part worth understanding:

```
mise activate fish   → puts project-local runtime shims first on PATH
zoxide init fish     → provides `z`, which `cd` is aliased to
atuin init fish      → replaces fish history, binds fuzzy search to the up arrow
starship init fish   → renders the prompt
fzf --fish           → Ctrl-T, Ctrl-R, Alt-C key bindings
direnv hook fish     → loads and unloads .envrc per directory
```

`direnv` is the one that matters most for keeping this repository clean. See
"Machine-local configuration" below.

### Shell history

atuin stores history in a local SQLite database with the working directory, exit
code, and duration recorded alongside each command, and binds fuzzy search to
the up arrow. It also offers an end-to-end encrypted sync server, which is *not*
configured here and is a deliberate choice: history is the most work-specific
thing on a machine, full of one employer's repository paths, AWS profiles, and
migration commands. Starting clean on a new machine is the correct default. Run
`atuin register` only if you decide otherwise.

---

## Git and SSH

### SSH keys

Generate a new key per machine rather than copying one around. A key that exists
on two machines cannot be revoked for one of them, and a key on a laptop you are
handing back is a key you no longer control.

```sh
ssh-keygen -t ed25519 -C "davidoduneye1@gmail.com"
pbcopy < ~/.ssh/id_ed25519.pub
```

Paste it at <https://github.com/settings/keys>, then verify — this step is worth
doing because a key that is present but not authorised fails in a way that looks
like a network problem:

```sh
ssh -T git@github.com     # expect: "Hi DOOduneye! You've successfully authenticated"
```

Then revoke the old machine's key from that same page once you no longer need it.

### Authentication

`~/.gitconfig` delegates credentials to the `gh` CLI, which stores its token in
the macOS keychain:

```
[credential "https://github.com"]
	helper =
	helper = !/opt/homebrew/bin/gh auth git-credential
```

The empty first value is not a typo. Git accumulates credential helpers rather
than replacing them, so an empty entry clears anything inherited from a system
or global config before the real helper is added. What it is clearing in
particular is `helper = store`, which was previously set here and which writes
tokens to `~/.git-credentials` in plaintext.

No install method preserves the token itself. Run `gh auth login` once per
machine, choosing SSH as the git protocol.

### Global gitignore

`core.excludesfile` points at `~/.gitignore_global`, which applies to every
repository on the machine. It is safe in repositories you do not control: it is
never committed, and it does not change what collaborators see.

The rule for what goes in it is worth stating because getting it wrong is
annoying for other people. Only machine and editor noise belongs here — things
that are true because of how *you* work. `.DS_Store`, `*.swp`, `.idea/`. Build
output, dependency directories, and anything every contributor would need
ignored belongs in the project's own `.gitignore` so that they get it too. If
you put `node_modules/` in your global file, it works for you and silently
breaks for the next person.

### difftastic

`diff.external = difft` makes `git diff` render structurally — it parses the
file and shows what changed syntactically rather than line by line, which is
much better for reformatted code and much worse for piping to another program.
When you need plain output, `git diff --no-ext-diff` bypasses it.

---

## macOS settings

The split between what is scripted and what is done by hand is not arbitrary, so
it is worth explaining the mechanism first.

System Settings and `defaults write` are not two systems. macOS stores
preferences in per-domain plist files under `~/Library/Preferences/`; System
Settings is a GUI that writes to them, and `defaults` writes to them directly.
Three consequences follow:

1. `defaults` can write values the GUI will not offer. Key repeat is the classic
   case — the fastest value System Settings exposes is 2, and 1 is faster still.
2. Applications read their domain once at launch and cache it in memory. A
   `defaults write` changes the file on disk and the running process never
   notices, which is why `killall Dock` or a logout is usually required. This is
   the single most common reason a `defaults` command appears to do nothing.
3. On macOS 13 and later, several trackpad and keyboard preferences are held by
   daemons that cache them aggressively and rewrite the plist when System
   Settings opens. Scripting those produces changes that silently revert.

So: script the settings the GUI cannot express, and set the rest by hand once.

### Scripted

`macos-defaults` is on `PATH` via `~/.local/bin`. It is run deliberately rather
than automatically on `chezmoi apply`, because it changes how the machine feels
and you should be looking at it when it does.

```sh
macos-defaults
```

It sets nine values, each one genuinely non-default on this machine, so it
reproduces a specific Mac rather than encoding somebody's opinion. The one that
is a real behaviour change is `ApplePressAndHoldEnabled`:

```
KeyRepeat 1 and InitialKeyRepeat 10   are measured in 15ms frames, not
                                      milliseconds. So ~15ms between repeats
                                      after a ~150ms delay. The GUI's fastest
                                      positions are 2 and 15.

ApplePressAndHoldEnabled false        has no checkbox anywhere in System
                                      Settings. Its default, `true`, makes
                                      holding a key open the accent picker —
                                      hold `e`, get è é ê ë — instead of
                                      repeating the character. Leaving it at
                                      the default is why fast key repeat feels
                                      inconsistent between applications.
```

The remaining six turn off the Dock launch bounce, set Dock magnification and
its size, stop macOS reordering Spaces so that Space 3 stays Space 3, stop a
title-bar double-click from minimising, and mute the system alert beep.

The Dock settings are live as soon as the script restarts Dock. The
`NSGlobalDomain` ones — key repeat, press-and-hold, double-click, alert volume —
are read by each application at launch, so log out and back in.

### By hand

This list is short, because most of what setup guides tell you to change is
already the macOS default. These are the values that are genuinely not.

```
Trackpad → Point & Click
    Tap to click            on          (macOS default is off)
    Tracking speed          0.875       (roughly one notch below maximum)
    Secondary click         Click or tap with two fingers
    Force Click             on          (already the default)
Trackpad → More Gestures
    Three finger drag       off         (already the default)

Appearance                  Dark
```

Secondary click is spelled out because the other option, "Click bottom right
corner", turns part of the trackpad surface into a right-click zone, so an
ordinary click near that corner does the wrong thing. Two-finger click has no
dead region. It is already off and the scripted settings do not touch it.

Everything else in the usual macOS-setup checklist is already correct out of the
box on this configuration and does not need changing: natural scrolling on,
autocorrect and smart quotes on, capitalisation and period substitution on,
screenshots saving to the Desktop as PNG, and no text replacements defined. If a
guide tells you to change one of those, it is a preference, not a fix.

Then whatever is personal to the machine and cannot be captured: Login Items,
Notifications, Focus modes, Touch ID, and the keyboard's modifier key and Fn
behaviour if you remap them.

### Security

FileVault and the firewall are usually enforced by MDM on a managed work
machine, so check what your employer's tooling has already done before changing
either. If they are yours to set:

```sh
fdesetup status
sudo fdesetup enable          # if off

/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

---

## Terminal

Ghostty, configured at `~/.config/ghostty/config` and managed by chezmoi.

Ghostty reads two paths on macOS: the XDG one above, and
`~/Library/Application Support/com.mitchellh.ghostty/config`. Ghostty creates the
Application Support copy as a commented template on first launch if it does not
find a config. Delete it — two files that can disagree is worse than one, and
the XDG path is where everything else lives.

```sh
rm -f ~/Library/Application\ Support/com.mitchellh.ghostty/config
ghostty +show-config          # prints what is actually in effect
```

The config sets the TokyoNight theme, JetBrains Mono Nerd Font at size 16, a
blinking bar cursor, `shift+enter` sending a literal newline for REPL-style
prompts, and fish as the launched shell.

The theme and cursor recreate a Tokyo Night profile that used to be a
Terminal.app `.terminal` file. Ghostty ships TokyoNight built in — along with
Night, Storm, Moon and Day variants — so there is nothing to import.
`ghostty +list-themes` shows them all.

Font family names have to match `ghostty +list-fonts` exactly. The installed
Nerd Font reports itself as `JetBrainsMono Nerd Font Mono`, where the trailing
"Mono" is part of the name rather than a description; dropping it gives you a
silent fallback to the default font rather than an error.

The Nerd Font matters beyond aesthetics — starship's git branch symbol and
several nvim UI elements are glyphs from it, and without it they render as
boxes. It comes from the Brewfile as `font-jetbrains-mono-nerd-font`.

`ghostty +validate-config` checks a config and exits non-zero with the offending
line if anything is wrong. Worth running after edits; it catches invalid theme
names and enum values, though not misspelled font families.

### tmux

Prefix is `Ctrl-a`. The configuration is documented in `README.md`; the one part
worth explaining here is the terminal declaration:

```
set -g default-terminal "tmux-256color"
set -ga terminal-features ",xterm-ghostty:RGB:hyperlinks:ccolour:sync:focus:title"
```

tmux strips capabilities it does not believe the outer terminal supports. These
lines tell it Ghostty does support them, so they pass through. `sync` is the one
that matters visibly — without it, wide blocks of output tear as they redraw.

`tmux-256color` has a history of breaking on macOS, which is why so much advice
still says to use `screen-256color`. Through roughly Monterey, Apple's bundled
ncurses shipped no `tmux-256color` terminfo entry and tmux would exit with
"missing or unsuitable terminal". The entry is present on macOS 15. Check with
`infocmp tmux-256color`, and if it is ever missing, compile it into a local
database rather than downgrading the setting:

```sh
/usr/bin/tic -x -o ~/.terminfo <(infocmp -x tmux-256color)
```

Plugins come from `.chezmoiexternal.toml`, which clones tpm, tmux-resurrect, and
tmux-continuum directly. There is no manual plugin install step; `chezmoi apply`
fetches them.

---

## Editors

nvim is the editor, and `vi` is aliased to it. The configuration is three files
and no framework:

```
~/.config/nvim/
    init.lua          options, keymaps, autocommands
    lua/plugins.lua   vim.pack.add plus each plugin's setup call
    lua/lsp.lua       vim.lsp.enable, diagnostics, LspAttach keymaps
```

It requires Neovim 0.12, and depends on two things that ship with it. `vim.pack`
is the built-in plugin manager: `vim.pack.add` clones anything missing and puts
it on the runtimepath, with no lockfile and no lazy-loading DSL. `vim.lsp.enable`
is the built-in LSP client configuration.

That second one is why there is no Mason. nvim-lspconfig is installed but never
required or set up — since v2 it ships `lsp/<server>.lua` files describing how to
launch each server, and `vim.lsp.enable` reads them straight off the
runtimepath. So lspconfig is pure data, and the server *binaries* come from
Homebrew instead of Mason.

The practical consequence: language support is only as good as what the Brewfile
installed. If a server does not attach, check the binary is on `PATH` before
suspecting the config. `:checkhealth lsp` lists what attached.

Treesitter needs one more thing. nvim-treesitter's `main` branch compiles
parsers using the `tree-sitter` CLI rather than bundling the compilation itself,
so `tree-sitter-cli` is in the Brewfile. Note that the `tree-sitter` formula is
the *library* and installs no binary — installing that one instead leaves you
with no syntax highlighting and a confusing error.

Parsers install on first launch, only for languages that are missing, so startup
does not spawn a job every time. Refresh them with
`:lua require("nvim-treesitter").update()`.

Updating plugins is `:lua vim.pack.update()`. Removing one means deleting its
line and its setup call from `plugins.lua`, then
`:lua vim.pack.del({ "name" })` to take it off disk.

`~/.vimrc` is a separate, deliberately minimal plain-vim configuration with no
plugin manager and no plugins. It exists so that vim is bearable when nvim is not
available: over ssh, inside a container, on a machine you do not control, or when
an nvim plugin update has broken something and you need to edit a file anyway.
Nothing in it can fail to load.

Zed is configured by `~/.config/zed/settings.json` and `keymap.json`, both
managed by chezmoi. Signing into Zed covers collaboration and its AI features; it
does not sync settings, so the files are the mechanism.

---

## Applications

What carries over, and what you re-do by hand:

```
Ghostty        config from chezmoi; delete the Application Support copy
Zed            settings and keymap from chezmoi; sign-in is collab/AI only
nvim           config from chezmoi; plugins install on first launch
Obsidian       the vault is just a folder. The account syncs vault contents
               only with paid Obsidian Sync — otherwise point Obsidian at the
               folder and re-enable community plugins by hand
Raycast        settings, hotkeys, snippets and quicklinks sync only on Raycast
               Pro (Cloud Sync). Without it, reconfigure by hand. The
               ask-claude script command comes from chezmoi
Claude         sign in
ChatGPT        sign in
Codex          sign in. ~/.codex/config.toml is mostly generated by the app
               with absolute paths; only model, model_reasoning_effort,
               approvals_reviewer and any custom MCP servers are yours to
               re-add
Slack          sign in per workspace
Chrome         sign in, profile syncs
Spotify        sign in
Zoom           sign in
Hidden Bar     reconfigure by hand, about a minute
AppCleaner     nothing to configure
```

Nothing carries `gh`, AWS, gcloud, or kubectl credentials, and it should not.
Those are per-employer and per-machine by nature.

---

## Claude Code

Three files are tracked, and two of them use a mechanism worth understanding.

`~/.claude/CLAUDE.md` is tracked normally. It holds communication-style rules
that apply to every project, so edits should propagate to every machine.

`~/.claude/settings.json` and `~/.claude/mcp.json` are tracked with chezmoi's
`create_` prefix, which means chezmoi writes them once on a machine that does
not have them and then never touches them again. `chezmoi status` stays silent
no matter how far they diverge.

That is deliberate, because Claude Code writes to `settings.json` itself — every
permission you approve is appended to it. Tracking it normally would mean either
constant drift in `chezmoi status` or `chezmoi apply` deleting approvals. With
`create_`, the repository holds a clean baseline, day-to-day approvals
accumulate locally, and a new machine starts from the baseline rather than
inheriting one employer's accumulated allowlist.

The baseline is small on purpose. The previous version of this file had grown to
199 permission entries, of which 64 referenced one employer's repositories and
tooling, and 14 were unmatched fragments of shell loops — entries like
`Bash(done)`, `Bash(EOF)`, and a `for` loop with eighteen literal commit SHAs.
That is what an allowlist becomes when it is only ever appended to.

What the baseline keeps: read-only file inspection, git operations that neither
rewrite history nor publish, the tools this setup installs (`gh`, `tmux`,
`chezmoi`, `brew`, `mise`, `obsidian` reads), web search, and documentation
domains. `defaultMode` stays `auto` so the workflow feels the same.

What it deliberately omits, so that each prompts once and you decide in context:
`rm`, `curl`, `source`, `chmod`, `sudo`, `python`, `git push`, `git reset`,
`git rebase`, and anything that reads secrets. Also every `Skill(...)` entry,
since skills are plugin- and project-scoped and will not be the same ones.

```sh
# reset a machine to the baseline
rm ~/.claude/settings.json && chezmoi apply ~/.claude/settings.json
```

One dependency worth knowing: `mcp.json` registers a `qmd` server, and `qmd` is
an npm global (`@tobilu/qmd`) installed under mise's node, not a Homebrew
formula. It is not in the Brewfile and will not exist on a new machine until it
is installed. The MCP server simply fails to start until then.

## Machine-local configuration

Two escape hatches exist so that nothing machine-specific or secret ever needs to
go in this repository.

**`~/.config/fish/conf.d/*.fish`** — fish sources every file in this directory
automatically. It is not managed by chezmoi and is not committed. Work aliases,
one-off `PATH` additions, and anything specific to one employer go here.

**`.envrc` per project, via direnv** — the better home for anything secret.
direnv loads environment variables when you enter a directory and unloads them
when you leave, so a token exists only while you are working in the project that
needs it, rather than being exported into every shell you open forever.

```sh
cd ~/work/some-project
echo 'export SOME_API_TOKEN="..."' > .envrc
direnv allow
```

Add `.envrc` to the project's `.gitignore`, or commit a non-secret `.envrc` that
sources an ignored `.envrc.local` — `~/.gitignore_global` already ignores
`.envrc.local` and `.direnv/`.

The rule: if it is a secret, it belongs in an `.envrc` or the keychain, never in
`config.fish`. This repository is public.

---

## Working with chezmoi day to day

chezmoi keeps a source directory at `~/.local/share/chezmoi`, which is an
ordinary git repository. Files there are named with prefixes that encode
destination and permissions: `dot_gitconfig` becomes `~/.gitconfig`,
`private_` sets 0600, `executable_` sets the executable bit, and `.tmpl` marks a
template.

```
chezmoi status        what differs between the repo and this machine
chezmoi diff          the same, in detail
chezmoi add <path>    pull a file on this machine into the repo
chezmoi apply         write the repo's version out to this machine
chezmoi update        pull from GitHub and apply in one step
chezmoi cd            open a shell in the source directory
```

`chezmoi status` is the one to run habitually. Its output means the machine and
the repository disagree, which is fine day to day and worth resolving before any
migration — a config that only exists on a laptop you are about to hand back is
a config you are about to lose.
