export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export ZSH="$HOME/.oh-my-zsh"

export EDITOR="nvim"
export TERMINAL="foot"

zstyle ':omz:update' mode reminder
ZSH_THEME="macovsky"

export PYTHON_VENV_NAME=".venv"
export PYTHON_AUTO_VRUN=true

plugins=(
	git
	colored-man-pages
	python
	archlinux
    uv
    vi-mode
)

source $HOME/.env_secrets
source $ZSH/oh-my-zsh.sh

alias neovim="nvim"

# Catppuccin Latte in foot for the duration of an SSH session, restored to
# whatever foot.ini loaded (Macchiato) on exit -- see
# ~/.local/bin/foot-theme. Guarded on -t 1 so it never fires when ssh's
# output is being piped/captured (git remotes, deploy scripts, etc.) --
# otherwise the escape sequences would land in whatever's capturing it.
# If ssh runs inside tmux, tmux needs `allow-passthrough on` to forward
# these through to foot instead of swallowing them (see tmux.conf).
ssh() {
    if [[ -t 1 ]] && (( $+commands[foot-theme] )); then
        foot-theme latte
        command ssh "$@"
        local exit_code=$?
        foot-theme reset
        return $exit_code
    fi
    command ssh "$@"
}
