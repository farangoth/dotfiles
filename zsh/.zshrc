export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
source $HOME/.env_secrets

ZSH_THEME="my-agnoster"

zstyle ':omz:update' mode reminder  

plugins=(
	git
	colored-man-pages
    virtualenv
    python
)

source $ZSH/oh-my-zsh.sh

alias neovim="nvim"
alias startqtile="qtile start -b wayland"

# eval "$(zellij setup --generate-auto-start zsh)"
