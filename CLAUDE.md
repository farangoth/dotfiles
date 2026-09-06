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
- **Theme**: Catppuccin Macchiato throughout all components

To reload the River config: `Super+Shift+C` (re-executes `~/.config/river/init`).

**Terminal**: foot (`foot/.config/foot/foot.ini`) is the default terminal (`TERM` in `river/.config/river/init`, `$TERMINAL` in zsh). Floating utility terminals (waybar/rofi quick-launchers) spawn `foot --app-id=term-float`, matched by the `term-float` river rule.

**Screenshots**: `Print` copies a full-screen shot to the clipboard (`grim | wl-copy`); `Super+Shift+S` copies a selected region (`grim -g "$(slurp)" | wl-copy`). Both land in cliphist automatically since `wl-paste --watch cliphist store` is already running.

**Clipboard**: `wl-clipboard` + `cliphist` back a single system clipboard shared by foot (`selection-target=clipboard`), tmux copy-mode, and Neovim (`clipboard=unnamedplus`). Tmux copy-mode relays via OSC 52 (`set-clipboard on`) rather than piping to `wl-copy` directly, so the same binding works locally (foot writes the OSC 52 payload to the real Wayland clipboard, which cliphist still picks up) and over SSH into a headless box with no Wayland session at all.

## Neovim Config

**Package manager**: Native `vim.pack` (Neovim 0.11+ built-in) — not lazy.nvim.

Entry point: `nvim/.config/nvim/init.lua` loads three modules in order:
1. `plugins/` — plugin declarations and setup (each file calls `vim.pack.add` then configures)
2. `config/` — options, keymaps
3. `custom/` — personal overrides

**Key plugins:**
- `snacks.nvim` — picker (files, grep, LSP navigation), explorer, git UI, zen mode, terminal
- `blink.cmp` — completion (super-tab preset, LSP/path/snippets/buffer sources)
- `codecompanion.nvim` — AI integration via Mistral (`MISTRAL_API_KEY` env var required)
- `mason.nvim` + `mason-lspconfig` — manages LSP servers (lua_ls, ruff, basedpyright, bashls)
- `which-key.nvim` — keymap groups
- `catppuccin` — colorscheme

**LSP servers** auto-installed by Mason. LSP format-on-save is always active (`BufWritePre`).

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
| `H` / `L` | Prev/next buffer |

## Zsh

Uses oh-my-zsh with `macovsky` theme. Python venvs auto-activated via the `uv` and `python` plugins (`PYTHON_AUTO_VRUN=true`, venv name `.venv`). Secrets sourced from `~/.env_secrets` (not in this repo).

**Minimal profile**: see the `raspi` package, below.

**SSH theme switch**: the `ssh` function wraps the real `ssh`, flipping foot to Catppuccin Frappe for the duration of the session and back to whatever `foot.ini` loaded (Macchiato) on exit — so the terminal itself signals "you're on a remote box" independently of anything the remote sends. Implemented via `~/.local/bin/foot-theme` (`foot/.local/bin/foot-theme`), which reads the actual `/usr/share/foot/themes/catppuccin-<name>` file and emits the corresponding OSC 4/10/11 dynamic-color sequences (reset via OSC 104/110/111/112) — nothing hardcoded, so it can't drift from the installed theme (Frappe's own background needs no dimming the way Latte's did, so unlike the very first version of this feature there's no override to keep in sync anywhere). Guarded on `[[ -t 1 ]]` so it never fires when `ssh`'s output is being piped or captured. Needs `allow-passthrough on` in tmux (already set) to reach foot when `ssh` runs inside a pane, since tmux otherwise swallows OSC sequences from programs running in it.

Frappe and Macchiato are both dark flavours, though, so the flip is subtler than Latte's was — mostly a base-color shift (`#303446` vs `#24273a`), not light-vs-dark. Two more explicit, textual signals back it up, both needing their own opt-in tmux option since tmux doesn't forward either by default:

- **Window title**: the same `ssh` function sets the window title to `SSH: <target>` on connect (a heuristic — the last argument, so `ssh host cmd args` would show the last arg instead) and clears it back to empty on exit, via a plain OSC 2 sequence. Waybar's `river/window` module shows the title live, so this surfaces there too. Needs `set-titles on` in tmux (already set) — off by default, same reason as `allow-passthrough`.
- **Tmux pane border**: `pane-border-format` shows each pane's running command on its own border, styled with `@thm_peach` specifically when that command is `ssh`. This is the one thing the whole-window color/title switch can't do on its own — OSC changes and the title are both window-scoped, so if only one pane in a multi-pane window is SSH'd, the other two signals still apply to the entire window; the pane border is genuinely per-pane.

## Tmux

`tmux/.config/tmux/tmux.conf` (XDG path, tmux 3.1+). Default prefix (`Ctrl-b`), vi copy-mode, Catppuccin Macchiato status line, mouse on. `Ctrl-h/j/k/l` move between tmux panes and Neovim splits seamlessly (mirrors the Neovim `<C-hjkl>` window-nav keymaps via a `pane_tty`/process check — no plugin needed). Copy-mode `y` uses tmux's OSC 52 clipboard relay (see Clipboard above) rather than a `wl-copy` pipe, so it works the same locally and over SSH.

## Raspberry Pi (`raspi` package)

Everything for the headless, SSH-only Pi lives in one stow package — `stow raspi` sets up both pieces in one shot:

- **`raspi/.config/nvim/init.lua`**: a single-file, dependency-free Neovim config — no plugin manager, no LSP/treesitter, built-ins only, so it starts instantly and works offline. Targets the same `~/.config/nvim` path as the main `nvim` package, so the two are **alternatives — never stow both on the same machine** (`stow` correctly refuses if you try; the repo's CI `stow -n` dry-run can't catch this specific case since each package is checked independently against a clean scratch `$HOME`). Colorscheme is Catppuccin Frappe, hand-rolled with plain `vim.api.nvim_set_hl` calls (no plugin manager to fetch catppuccin.nvim with) — matches the theme foot itself switches to for the SSH session this nvim normally runs inside (see SSH theme switch above). A `[PI]` window-title tag adds a second signal.
- **`raspi/.zshrc`**: trimmed oh-my-zsh setup — no `archlinux` plugin (wrong OS on Raspberry Pi OS/Debian), no Python venv auto-activation, stock `robbyrussell` theme instead of `macovsky` (guaranteed present without extra setup), and no hardcoded `SSH_AUTH_SOCK` (would clobber the one `sshd` sets via agent forwarding, breaking `ssh -A`). Same `~/.zshrc` target as the main `zsh` package — alternatives, never stow both.

The Wayland desktop stack above (river, waybar, mako, rofi, kanshi, swayidle, swaylock, foot, kitty) doesn't apply here — the Pi has no display and no Wayland session.
