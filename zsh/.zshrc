export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

ZSH_THEME="agnoster"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(
	git
	colored-man-pages
    virtualenv
    python
)

source $ZSH/oh-my-zsh.sh

alias neovim="nvim"
alias startqtile="qtile start -b wayland"
