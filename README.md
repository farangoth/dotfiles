# dotfiles

[![CI](https://github.com/farangoth/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/farangoth/dotfiles/actions/workflows/ci.yml)

Personal dotfiles for three machines: an Arch Linux desktop (River/Wayland), a headless Raspberry Pi, and a macOS work laptop. Managed with [GNU Stow](https://www.gnu.org/software/stow/) — each top-level directory is a package that mirrors the paths it symlinks into `$HOME`.

See [`CLAUDE.md`](./CLAUDE.md) for the detailed breakdown of every package and how the pieces fit together (theme switching, clipboard, keymaps, etc.); this file is the quickstart.

## Layout

| Package | What it is |
|---|---|
| `river`, `waybar`, `mako`, `rofi`, `kanshi`, `swayidle`, `swaylock`, `foot` | Arch desktop: window manager, bar, notifications, launcher, display/idle/lock, terminal |
| `nvim` | Neovim config (native `vim.pack`, Neovim 0.12+) — shared by the desktop and macOS |
| `tmux` | Tmux config — shared by the desktop and macOS |
| `zsh` | Full oh-my-zsh setup for the desktop |
| `raspi` | Headless Pi profile — dependency-free nvim, trimmed zsh. **Alternative to `nvim`/`zsh`, additive with `tmux`** |
| `macos` | Work laptop profile — zsh adapted for macOS, iTerm2 Catppuccin profiles. **Alternative to `zsh`, additive with `nvim`/`tmux`** |

Theme is [Catppuccin](https://github.com/catppuccin) throughout: **Mocha** on the desktop and macOS, switching to **Frappe** for the duration of any SSH session as a "you're on a remote box" signal.

Every zshrc auto-attaches to a tmux session on interactive login, so tmux's own bindings are the only ones that matter regardless of which terminal (foot, iTerm2) is attached. `dev [dir]` opens a three-pane `nvim`/`claude`/shell session rooted in that directory (`tmux-dev`, shared via the `tmux` package).

## Setup

Clone this repo, then run the bootstrap script — it detects which of the three machines you're on (`uname`, plus a Raspberry Pi check via `/proc/cpuinfo`/`/proc/device-tree/model`) and runs the right `stow`/`brew bundle` commands, or take an explicit profile if you'd rather not rely on auto-detection:

```sh
git clone <repo-url> ~/dotfiles && cd ~/dotfiles
./install.sh                  # auto-detects desktop/pi/macos
./install.sh desktop|pi|macos # or pick explicitly
```

What each profile actually runs, if you'd rather do it by hand (or `install.sh` can't detect your machine):

**Arch desktop:**
```sh
stow river waybar mako rofi kanshi swayidle swaylock foot nvim tmux zsh
```

**Raspberry Pi (headless, SSH-only):**
```sh
stow raspi
```

**macOS (work laptop):**
```sh
brew bundle --file=Brewfile   # installs stow, neovim, tmux, fzf, zoxide, eza, bat,
                               # ripgrep, lazygit, iTerm2, a Nerd Font
stow nvim tmux macos
```
(oh-my-zsh isn't brew-installable — install it separately, then stow.)

Doing it by hand also skips `install.sh`'s tmux plugin bootstrap (clones [TPM](https://github.com/tmux-plugins/tpm) and installs [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key) headlessly) — install TPM yourself and press `prefix + I` inside tmux instead.

Re-run with `stow --restow <package>` after adding files to a package, or `stow --delete <package>` to unlink.

`raspi` and `zsh` target the same `~/.zshrc` and are **alternatives** — never stow both on the same machine (`stow` will refuse). Same for `raspi` and `nvim` on `~/.config/nvim`.

## CI

Every push to `main` and every PR runs shellcheck, luacheck, a `river/init` syntax check, a waybar JSONC sanity check, and a `stow -n` dry-run of every package to catch symlink conflicts before they hit `$HOME`. There's no CD — dotfiles aren't deployed; `stow` is run by hand on whichever machine you're setting up. See [`.github/workflows/ci.yml`](./.github/workflows/ci.yml).
