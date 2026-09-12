export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode disabled

ZSH_THEME="macovsky"

plugins=(
    git
    colored-man-pages
    vi-mode
)

[[ -f "$HOME/.env_secrets" ]] && source "$HOME/.env_secrets"
source "$ZSH/oh-my-zsh.sh"

alias neovim="nvim"

cc() { tmux-claude "${1:-$PWD}"; }

chpwd() { [[ -t 1 ]] && printf '\033]2;%s\033\\' "$PWD"; }

if [[ -z "$TMUX" && -o interactive && -t 1 ]]; then
    exec tmux new-session -A -s main
fi
