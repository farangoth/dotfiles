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

prompt_virtualenv() {
  if [ -n "$CONDA_DEFAULT_ENV" ]; then
    prompt_segment magenta $CURRENT_FG "🐍 $CONDA_DEFAULT_ENV"
  fi
  if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
    local venv_path=$(dirname "$VIRTUAL_ENV")
    local project_name=$(basename "$venv_path")


    prompt_segment "$AGNOSTER_VENV_BG" "$AGNOSTER_VENV_FG" "(${project_name:t:gs/%/%%})"
  fi
}

alias neovim="nvim"
alias startqtile="qtile start -b wayland"
