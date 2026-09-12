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
ZSH_THEME="macovsky"  # oh-my-zsh's stock default -- zero extra assets
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

# Dedicated tmux session for Claude Code (tmux-claude, this package's own
# script -- see there for the idempotent attach-or-create logic, mirroring
# tmux/.local/bin/tmux-dev's pattern). Named `cc`, not `claude`, so it
# doesn't shadow the real `claude` binary -- typing `claude` directly here
# still just runs the CLI in the current shell/pane.
cc() { tmux-claude "${1:-$PWD}"; }

# -- report cwd via the window title, for whoever's ssh'd into this box --
# tmux can only read pane_current_path off its own local pty, so a pane
# running `ssh` always shows wherever `ssh` itself was launched FROM, never
# wherever `cd` takes you on the far end -- there's no way for the local
# tmux to inspect a remote shell's cwd directly. OSC 2 (window title)
# sidesteps that: it's just bytes in the pty stream, so it crosses the ssh
# connection like any other terminal escape sequence and updates the
# *local* pane's title (tmux's pane_title) same as if it came from a local
# program. The status bar's SSH-branch cwd pill reads #{pane_title} instead
# of #{pane_current_path} for exactly this reason (see tmux.conf) -- this
# matters most for raspi specifically, since it's normally always accessed
# over ssh (see "always inside tmux" below). Defined as a bare `chpwd` (not
# add-zsh-hook) -- zsh calls any function with that exact name
# automatically on every directory change and once at shell startup, no
# registration needed. Guarded on -t 1 so it doesn't leak escape codes into
# piped/captured output.
chpwd() { [[ -t 1 ]] && printf '\033]2;%s\033\\' "$PWD"; }

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
