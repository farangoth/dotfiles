# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

Arch Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package containing the full config path (e.g., `nvim/.config/nvim/`). To symlink a package into `$HOME`:

```sh
stow <package>          # e.g. stow nvim
stow --delete <package> # remove symlinks
stow --restow <package> # re-link (useful after adding files)
```

**CI** (`.github/workflows/ci.yml`): on every push to `main` and every PR, runs shellcheck on the rofi scripts, luacheck on the nvim Lua config (see `.luacheckrc`), a syntax check of `river/init`, a JSONC sanity check of waybar's config, and a `stow -n` dry-run of every package to catch symlink conflicts before they hit `$HOME`. There's no CD — a dotfiles repo isn't deployed anywhere; `stow` is run by hand on whichever machine you're setting up.

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

**Clipboard**: `wl-clipboard` + `cliphist` back a single system clipboard shared by foot (`selection-target=clipboard`), tmux copy-mode, and Neovim (`clipboard=unnamedplus`).

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

## Tmux

`tmux/.config/tmux/tmux.conf` (XDG path, tmux 3.1+). Default prefix (`Ctrl-b`), vi copy-mode, Catppuccin Macchiato status line, mouse on. `Ctrl-h/j/k/l` move between tmux panes and Neovim splits seamlessly (mirrors the Neovim `<C-hjkl>` window-nav keymaps via a `pane_tty`/process check — no plugin needed). Copy-mode `y` pipes the selection to `wl-copy` so it lands in the same clipboard/cliphist as everything else.
