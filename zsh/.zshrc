export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

export EDITOR="nvim"
export TERMINAL="kitty"

zstyle ':omz:update' mode reminder
ZSH_THEME="macovsky"

plugins=(
	git
	colored-man-pages
	python
	archlinux
)

source $ZSH/oh-my-zsh.sh

alias neovim="nvim"
alias cat="bat"
