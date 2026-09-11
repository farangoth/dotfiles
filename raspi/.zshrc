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
# `exec`, not a plain call, so once `main` ends there's no remote shell
# left to fall back to -- the SSH connection itself closes (standard SSH
# behavior once the remote command exits) instead of dropping you into a
# bare remote prompt (see zsh/.zshrc for the live confirmation of exec vs
# non-exec here). `new-session -A` attaches if `main` exists or creates
# it, atomically.
if [[ -z "$TMUX" && -o interactive && -t 1 ]]; then
    exec tmux new-session -A -s main
fi
