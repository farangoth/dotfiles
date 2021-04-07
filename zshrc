export ZSH="/home/farangoth/.oh-my-zsh"

ZSH_THEME="agnoster"

DEFAULT_USER="farangoth"
prompt_context(){}

source $ZSH/oh-my-zsh.sh

# User configuration

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

source ~/.shell/aliases
source ~/.shell/functions
source ~/.shell/variables

# Virtual envs
source $HOME/.local/bin/virtualenvwrapper.sh

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
