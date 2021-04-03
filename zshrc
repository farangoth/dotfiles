export ZSH="/home/farangoth/.oh-my-zsh"

ZSH_THEME="agnoster"

DEFAULT_USER="farangoth"
prompt_context(){}

source $ZSH/oh-my-zsh.sh

# User configuration

. ~/.shell/aliases
. ~/.shell/functions
. ~/.shell/variables

plugins=(
	sudo
	systemd
	colored-man-pages
	git
	virtualenvwrapper
	ssh-agent         # Start script
	colorize          # Syntax highlight for cat
	django
	pip
	virtualenvwrapper
)

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev
source /usr/bin/virtualenvwrapper.sh
