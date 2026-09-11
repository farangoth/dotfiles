# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

Arch Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package containing the full config path (e.g., `nvim/.config/nvim/`). To symlink a package into `$HOME`:

```sh
stow <package>          # e.g. stow nvim
stow --delete <package> # remove symlinks
stow --restow <package> # re-link (useful after adding files)
```

**CI** (`.github/workflows/ci.yml`): on every push to `main` and every PR, runs shellcheck on the rofi scripts and `foot-theme`, luacheck on the nvim Lua config (see `.luacheckrc`), a syntax check of `river/init`, a JSONC sanity check of waybar's config, and a `stow -n` dry-run of every package to catch symlink conflicts before they hit `$HOME`. There's no CD — a dotfiles repo isn't deployed anywhere; `stow` is run by hand on whichever machine you're setting up.

## Wayland Desktop Stack

- **WM**: River (config: `river/.config/river/init` — a Python script run by River on startup)
- **Bar**: Waybar (`waybar/.config/waybar/config.jsonc` + `style.css`)
- **Notifications**: Mako (`mako/.config/mako/config`)
- **Launcher**: Rofi (`rofi/.config/rofi/`) with custom shell scripts in `scripts/`
- **Idle/lock**: Swayidle + Swaylock
- **Display management**: Kanshi (auto-switch output profiles: `nomad`, `clamshell`, `dual`)
- **Theme**: Catppuccin Mocha throughout all components

To reload the River config: `Super+Shift+C` (re-executes `~/.config/river/init`).

**Terminal**: foot (`foot/.config/foot/foot.ini`) is the default terminal (`TERM` in `river/.config/river/init`, `$TERMINAL` in zsh). Floating utility terminals (waybar/rofi quick-launchers) spawn `foot --app-id=term-float`, matched by the `term-float` river rule.

**Screenshots**: `Print` copies a full-screen shot to the clipboard (`grim | wl-copy`); `Super+Shift+S` copies a selected region (`grim -g "$(slurp)" | wl-copy`). Both land in cliphist automatically since `wl-paste --watch cliphist store` is already running.

**Clipboard**: `wl-clipboard` + `cliphist` back a single system clipboard shared by foot (`selection-target=clipboard`), tmux copy-mode, and Neovim (`clipboard=unnamedplus`). Tmux copy-mode relays via OSC 52 (`set-clipboard on`) rather than piping to `wl-copy` directly, so the same binding works locally (foot writes the OSC 52 payload to the real Wayland clipboard, which cliphist still picks up) and over SSH into a headless box with no Wayland session at all.

## Neovim Config

**Package manager**: Native `vim.pack` (Neovim 0.12+ built-in — confirmed absent on 0.11.4, present on nightly/0.12) — not lazy.nvim.

Entry point: `nvim/.config/nvim/init.lua` loads three modules in order:
1. `plugins/` — plugin declarations and setup (each file calls `vim.pack.add` then configures)
2. `config/` — options, keymaps
3. `custom/` — personal overrides

**Key plugins:**
- `snacks.nvim` — picker (files, grep, LSP navigation), explorer, git UI, zen mode, terminal, notifier (`vim.notify` UI)
- `blink.cmp` — completion (super-tab preset, LSP/path/snippets/buffer sources)
- `codecompanion.nvim` — AI integration via Mistral (`MISTRAL_API_KEY` env var required)
- `mason.nvim` + `mason-lspconfig` — manages LSP servers (lua_ls, ruff, basedpyright, bashls, jsonls, yamlls, taplo, cssls, html)
- `conform.nvim` — formatting (stylua for lua, shfmt for sh/bash, falls back to the LSP formatter for everything else)
- `gitsigns.nvim` — inline hunk signs, staging/reset/preview, inline blame toggle
- `nvim-surround` — add/change/delete surrounding pairs
- `todo-comments.nvim` — highlights + quickfix listing of TODO/FIXME/HACK comments
- `which-key.nvim` — keymap groups
- `catppuccin` — colorscheme

**LSP servers** auto-installed by Mason. **Formatters** (stylua, shfmt) are not — install with `:MasonInstall stylua shfmt` or the system package manager, since `mason-lspconfig`'s `ensure_installed` only covers LSP servers.

**Format-on-save** lives in `plugins/conform.lua`, not `plugins/lsp.lua` — conform's own `format_on_save` (gated on `vim.g.autoformat`, toggle with `<leader>tf`) with `lsp_format = "fallback"` replaced the old `LspAttach`/`BufWritePre`/`vim.lsp.buf.format` autocmd in `lsp.lua`, so there's one format-on-save mechanism instead of two that could compete.

**Adding a new plugin**: Call `vim.pack.add("url")` at the top of the relevant file in `lua/plugins/`, then configure below it. Run `:lua vim.pack.update()` (or `<leader>pu`) to fetch.

**Lua LSP**: `.luarc.json` at the repo root declares `vim` as a global for lua_ls diagnostics.

**Minimal profile**: see the `raspi` package, below.

## Key Neovim Keymaps

Leader is `Space`.

| Key | Action |
|-----|--------|
| `<leader><space>` | Smart file picker |
| `<leader>ff` | File picker |
| `<leader>sf` | Grep files |
| `<leader>e` | File explorer |
| `<leader>gg` | Lazygit |
| `<leader>ma` | CodeCompanion actions |
| `<leader>mt` | Toggle AI chat |
| `<leader>pu` | Update packages |
| `<leader>pm` | MasonUpdate |
| `<leader>tf` | Toggle format-on-save |
| `<leader>gp` / `ga` / `gr` | Preview / stage / reset git hunk |
| `<leader>tb` | Toggle inline git blame |
| `]h` / `[h` | Next/prev git hunk |
| `<leader>st` | Search TODO comments (quickfix) |
| `<leader>rt` | Add a TODO comment (commented per filetype, drops into insert) |
| `H` / `L` | Prev/next buffer |

## Zsh

Uses oh-my-zsh with `macovsky` theme. Python venvs auto-activated via the `uv` and `python` plugins (`PYTHON_AUTO_VRUN=true`, venv name `.venv`). Secrets sourced from `~/.env_secrets` (not in this repo).

**Minimal profile**: see the `raspi` package, below.

**Always inside tmux**: every zshrc (`zsh`, `macos`, `raspi`) attaches to (or creates) a tmux session named `main` at the end of an interactive shell login, guarded on `[[ -z "$TMUX" && -o interactive && -t 1 ]]` — so it never fires inside an already-running tmux pane, a non-interactive shell, or a script/cron context. The point is coherence: with this in place there's no "outside tmux" state on any machine, so tmux's own bindings are the only bindings that matter, identical whether the outer terminal is foot or iTerm2.

**`dev` profile**: `dev` (in `zsh`/`macos`, not `raspi`) calls `tmux-dev` (`tmux/.local/bin/tmux-dev`, shared — pure bash + tmux, no OS-specific bits), which opens a three-pane tmux window rooted in the given directory (`$PWD` if omitted): `nvim`, `claude`, and a plain shell. Idempotent — reattaches instead of duplicating if a session already exists for that directory (session name is `dev-<basename>`).

**SSH theme switch**: the `ssh` function wraps the real `ssh`, flipping foot to Catppuccin Frappe for the duration of the session and back to whatever `foot.ini` loaded (Mocha) on exit — so the terminal itself signals "you're on a remote box" independently of anything the remote sends. Implemented via `~/.local/bin/foot-theme` (`foot/.local/bin/foot-theme`), which reads the actual `/usr/share/foot/themes/catppuccin-<name>` file and emits the corresponding OSC 4/10/11 dynamic-color sequences (reset via OSC 104/110/111/112) — nothing hardcoded, so it can't drift from the installed theme (Frappe's own background needs no dimming the way Latte's did, so unlike the very first version of this feature there's no override to keep in sync anywhere). Guarded on `[[ -t 1 ]]` so it never fires when `ssh`'s output is being piped or captured. Needs `allow-passthrough on` in tmux (already set) to reach foot when `ssh` runs inside a pane, since tmux otherwise swallows OSC sequences from programs running in it.

Frappe and Mocha are both dark flavours, though, so the flip is subtler than Latte's was — mostly a base-color shift (`#303446` vs `#1e1e2e`), not light-vs-dark. Two more explicit, textual signals back it up, both needing their own opt-in tmux option since tmux doesn't forward either by default:

- **Window title**: the same `ssh` function sets the window title to `SSH: <target>` on connect (a heuristic — the last argument, so `ssh host cmd args` would show the last arg instead) and clears it back to empty on exit, via a plain OSC 2 sequence. Waybar's `river/window` module shows the title live, so this surfaces there too. Needs `set-titles on` in tmux (already set) — off by default, same reason as `allow-passthrough`. `set-titles-string "#T"` makes this a clean passthrough of the pane title; without it tmux wraps it in its own default `session:window - title` format.
- **Tmux window name**: the same `ssh` function also does `tmux rename-window "ssh:$target"` on connect when `$TMUX` is set, restoring `automatic-rename` on exit rather than trying to restore a captured name (simpler, and avoids restoring a stale auto-generated name) — the outer-terminal title is one shared string for the whole terminal, so it can't distinguish which tmux window you're looking at; the window name can. Trade-off: if you'd manually renamed that window yourself before connecting, `automatic-rename on` on exit clobbers it back to tracking the running command.
- **Tmux pane border**: `pane-border-format` shows each pane's running command on its own border, styled with `@thm_peach` specifically when that command is `ssh`. This is the one thing the whole-window color/title switch can't do on its own — OSC changes and the title are both window-scoped, so if only one pane in a multi-pane window is SSH'd, the other two signals still apply to the entire window; the pane border is genuinely per-pane.
- **Tmux status bar**: `status-style` shifts to Catppuccin Frappe (`@thm_frappe_*`) when the *focused* pane's `pane_current_command` is `ssh`, same ternary technique and same per-pane-focus caveat as the border above. Set with plain `set -g`, not `-gF` — confirmed live in a real tmux session that `-gF` bakes a ternary into a static value at the moment it's set (fine for the plain `@thm_*` lookups elsewhere in this file, which never change after load) rather than re-evaluating it on every render the way a condition depending on `pane_current_command` needs; `pane-border-format` below was already doing this correctly (plain `set -g`), which is what exposed the mismatch.

## Tmux

`tmux/.config/tmux/tmux.conf` (XDG path, tmux 3.1+). Default prefix (`Ctrl-b`), vi copy-mode, Catppuccin Mocha status line, mouse on. `Ctrl-h/j/k/l` move between tmux panes and Neovim splits seamlessly (mirrors the Neovim `<C-hjkl>` window-nav keymaps via a `pane_tty`/process check — no plugin needed). Copy-mode `y` uses tmux's OSC 52 clipboard relay (see Clipboard above) rather than a `wl-copy` pipe, so it works the same locally and over SSH.

**`tmux-dev`** (`tmux/.local/bin/tmux-dev`): the `dev` profile launcher — see Zsh above.

## Raspberry Pi (`raspi` package)

The Pi-specific pieces live in one stow package — `stow raspi tmux` sets the Pi up (`tmux` is the same OS-agnostic package the desktop and macOS use, worth having here too for the auto-start-on-login/SSH-resilience benefit — see Zsh above):

- **`raspi/.config/nvim/init.lua`**: a single-file, dependency-free Neovim config — no plugin manager, no LSP/treesitter, built-ins only, so it starts instantly and works offline. Targets the same `~/.config/nvim` path as the main `nvim` package, so the two are **alternatives — never stow both on the same machine** (`stow` correctly refuses if you try; the repo's CI `stow -n` dry-run can't catch this specific case since each package is checked independently against a clean scratch `$HOME`). Colorscheme is Catppuccin Frappe, hand-rolled with plain `vim.api.nvim_set_hl` calls (no plugin manager to fetch catppuccin.nvim with) — matches the theme foot itself switches to for the SSH session this nvim normally runs inside (see SSH theme switch above). A `[PI]` window-title tag adds a second signal.
- **`raspi/.zshrc`**: trimmed oh-my-zsh setup — no `archlinux` plugin (wrong OS on Raspberry Pi OS/Debian), no Python venv auto-activation, stock `robbyrussell` theme instead of `macovsky` (guaranteed present without extra setup), and no hardcoded `SSH_AUTH_SOCK` (would clobber the one `sshd` sets via agent forwarding, breaking `ssh -A`). Same `~/.zshrc` target as the main `zsh` package — alternatives, never stow both.

The Wayland desktop stack above (river, waybar, mako, rofi, kanshi, swayidle, swaylock, foot, kitty) doesn't apply here — the Pi has no display and no Wayland session.

## macOS (`macos` package, work laptop)

Unlike `raspi`, this isn't a from-scratch alternative to the main packages — `nvim` and `tmux` are already OS-agnostic (Mason fetches per-OS binaries, clipboard integration doesn't depend on Wayland) and get stowed as-is: `stow nvim tmux macos` on this machine. Only zsh needed a macOS-specific variant, plus two pieces with no Linux equivalent at all:

- **`macos/.zshrc`**: adapted from `zsh/.zshrc` — adds `eval "$(/opt/homebrew/bin/brew shellenv)"` (Apple Silicon Homebrew PATH, no Linux equivalent), drops the `archlinux` oh-my-zsh plugin (wrong OS, same fix as `raspi`), drops the hardcoded `SSH_AUTH_SOCK` (macOS SSH agents — Secretive, 1Password, launchd's own — set their own socket; hardcoding one would clobber it, the same class of bug `raspi` avoids for `ssh -A`), and drops `$TERMINAL` (nothing shells out to it here). Same `~/.zshrc` target as `zsh`/`raspi` — alternatives, never stow more than one at once.
- **SSH theme switch, iTerm2 version**: the `ssh` function switches iTerm2 profiles via its proprietary OSC 50 `SetProfile` sequence (`SSH-Frappe` on connect, `Default` on exit) instead of the desktop's `foot-theme` script, since foot's theme files don't exist on macOS. The two profiles (Catppuccin Mocha `Default`, Catppuccin Frappe `SSH-Frappe`) are declared in `macos/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json` — iTerm2 loads dynamic profiles from that directory automatically, no import step needed. **Not verified against a real iTerm2 session** — built from iTerm2's documented OSC 50 syntax, not live-tested; confirm the profile actually flips (and that tmux's `allow-passthrough on` is sufficient to forward OSC 50 through a pane) on the actual laptop. The window-title OSC 2 signal is unchanged from the desktop version.
- **`Brewfile`** (repo root, like `.luarc.json` — a repo utility file, not stowed into `$HOME`): `brew bundle --file=Brewfile` installs everything the stowed configs expect on PATH (stow itself, neovim, tmux, fzf, zoxide, eza, bat, ripgrep, lazygit, iTerm2, a Nerd Font for `eza --icons`/Snacks icons). oh-my-zsh isn't brew-installable — run its installer separately.

The Wayland desktop stack, `raspi`'s minimal nvim, and the tmux pane-border SSH indicator's `@thm_peach` styling all still apply unchanged; only the parts that are genuinely Linux/Wayland/foot-specific needed a macOS counterpart.
