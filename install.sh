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

# tmux is stowed on every profile, so this runs once at the end rather
# than being duplicated per-branch. Clones TPM (tmux plugin manager) if
# it isn't already there, then runs its headless installer so plugins
# (tmux-which-key) are ready without a manual `prefix + I` -- tmux.conf's
# own `if "test -f ...tpm/tpm"` guard is what keeps sourcing the config
# safe before this has ever run (a fresh checkout, or CI).
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
    stow river waybar mako rofi kanshi swayidle swaylock foot kitty nvim tmux zsh
    ;;
pi)
    echo "==> Raspberry Pi (headless) profile"
    require_stow
    stow raspi tmux
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
    ;;
*)
    echo "install.sh: unknown profile '$profile' (expected desktop, pi, or macos)" >&2
    exit 1
    ;;
esac

setup_tmux_plugins

echo "==> Done."
