export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(
	git
	colored-man-pages
)

source $ZSH/oh-my-zsh.sh

alias neovim="nvim"
alias startqtile="qtile start -b wayland"
