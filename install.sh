#!/usr/bin/env bash
# Bootstrap: stow the right packages for this machine.
# Usage: ./install.sh [desktop|pi|macos]   -- profile auto-detected if omitted
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

profile="${1:-}"

if [[ -z "$profile" ]]; then
    case "$(uname -s)" in
    Darwin) profile="macos" ;;
    Linux)
        if grep -qi "raspberry pi" /proc/cpuinfo 2>/dev/null ||
            { [[ -r /proc/device-tree/model ]] && grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null; }; then
            profile="pi"
        else
            profile="desktop"
        fi
        ;;
    esac
fi

if [[ -z "$profile" ]]; then
    echo "install.sh: couldn't detect this machine's profile automatically." >&2
    echo "Run again with: ./install.sh desktop|pi|macos" >&2
    exit 1
fi

require_stow() {
    command -v stow >/dev/null 2>&1 || {
        echo "install.sh: stow not found. Install it first (pacman -S stow / apt install stow)." >&2
        exit 1
    }
}

# Every zsh-driven behavior in this repo (tmux auto-attach, the SSH cwd
# hook, oh-my-zsh itself) is dead weight if zsh isn't actually the login
# shell -- stowing .zshrc alone does nothing on a box whose account still
# defaults to bash. chsh normally prompts for the account password
# interactively, which is fine since this script itself is run by hand.
ensure_zsh_login_shell() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "install.sh: zsh not found -- install it first (pacman -S zsh / apt install zsh), then re-run this script or run 'chsh -s \$(command -v zsh)' by hand. Without it as the login shell, .zshrc (tmux auto-attach, the SSH cwd hook, etc.) never loads on login." >&2
        return
    fi
    local zsh_path
    zsh_path="$(command -v zsh)"
    # chsh refuses to set a shell that isn't listed in /etc/shells -- on
    # Debian/Raspberry Pi OS specifically, `apt install zsh` doesn't always
    # register it there, so chsh below would otherwise fail with "shell
    # not listed in /etc/shells" and (under set -e) abort this whole
    # script. Idempotent: no-ops if the line's already there (already the
    # case on Arch, whose zsh package registers it on install).
    if ! grep -Fxq "$zsh_path" /etc/shells 2>/dev/null; then
        echo "==> Registering $zsh_path in /etc/shells (you may be prompted for your password)"
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    if [[ "${SHELL:-}" != "$zsh_path" ]]; then
        echo "==> Setting zsh as the default login shell (you may be prompted for your password)"
        chsh -s "$zsh_path"
        echo "==> Done -- this takes effect on your NEXT login (new SSH connection or terminal), not the current session."
    fi
}

# Only desktop/macos stow the shared tmux package (which uses TPM) --
# raspi has its own plugin-free tmux config (raspi/.config/tmux), so this
# is called from those two branches specifically, not unconditionally.
# Clones TPM (tmux plugin manager) if it isn't already there, then runs
# its headless installer so plugins (tmux-which-key) are ready without a
# manual `prefix + I` -- tmux.conf's own `if "test -f ...tpm/tpm"` guard
# is what keeps sourcing the config safe before this has ever run (a
# fresh checkout, or CI).
setup_tmux_plugins() {
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
        echo "==> Cloning TPM (tmux plugin manager)"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi
    if command -v tmux >/dev/null 2>&1; then
        echo "==> Installing tmux plugins"
        "$tpm_dir/bin/install_plugins"
    else
        echo "install.sh: tmux not found yet -- skipping plugin install (run 'prefix + I' inside tmux, or re-run this script, once tmux is installed)." >&2
    fi
}

case "$profile" in
desktop)
    echo "==> Desktop (Arch/river) profile"
    require_stow
    stow river waybar mako rofi kanshi swayidle swaylock foot nvim tmux zsh
    ensure_zsh_login_shell
    setup_tmux_plugins
    ;;
pi)
    echo "==> Raspberry Pi (headless) profile"
    require_stow
    stow raspi
    ensure_zsh_login_shell
    ;;
macos)
    echo "==> macOS (work laptop) profile"
    command -v brew >/dev/null 2>&1 || {
        echo "install.sh: Homebrew not found. Install it first: https://brew.sh" >&2
        exit 1
    }
    brew bundle --file=Brewfile
    stow nvim tmux macos
    echo "Note: oh-my-zsh isn't brew-installable -- install it separately if not already present."
    setup_tmux_plugins
    ;;
*)
    echo "install.sh: unknown profile '$profile' (expected desktop, pi, or macos)" >&2
    exit 1
    ;;
esac

echo "==> Done."
