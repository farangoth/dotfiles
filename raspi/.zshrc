# Minimal zsh profile for headless/SSH-only machines (Raspberry Pi). Same
# oh-my-zsh base as the desktop's zsh package, trimmed to what actually
# applies on a box with no display and (usually) no Arch/pacman underneath.
# Alternative to the main zsh package -- same ~/.zshrc target, stow one or
# the other, never both.

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"

# No $TERMINAL/SSH_AUTH_SOCK export here: there's no GUI terminal to spawn
# on a headless box, and hardcoding SSH_AUTH_SOCK to a systemd user socket
# that doesn't exist here would clobber the SSH_AUTH_SOCK that sshd already
# sets when you connect with agent forwarding (ssh -A).

zstyle ':omz:update' mode disabled
ZSH_THEME="robbyrussell"  # oh-my-zsh's stock default -- zero extra assets
                          # to install, so it's never the thing missing on
                          # a fresh box. Swap back to "macovsky" if it's
                          # already set up here too.

plugins=(
    git
    colored-man-pages
    vi-mode
)

[[ -f "$HOME/.env_secrets" ]] && source "$HOME/.env_secrets"
source "$ZSH/oh-my-zsh.sh"

alias neovim="nvim"

# -- always inside tmux -- the classic benefit here: an SSH session that
# drops doesn't lose your work, just reattach. Skips non-interactive
# shells, anything without a real tty, and shells already inside tmux.
if [[ -z "$TMUX" && -o interactive && -t 1 ]]; then
    tmux attach -t main || tmux new -s main
fi
