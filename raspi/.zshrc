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

function git_prompt_segment() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) || ref=$(git rev-parse --short HEAD 2>/dev/null) || return
  local status_text lines branch_line flags=""
  status_text=$(git status --porcelain --branch 2>/dev/null)
  lines=("${(@f)status_text}")
  branch_line="${lines[1]}"
  (( ${#lines} > 1 )) && flags+="*"
  [[ "$branch_line" == *ahead* ]] && flags+="+"
  [[ "$branch_line" == *behind* ]] && flags+="-"
  echo "%{$fg[yellow]%}< ${ref}${flags:+ $flags} >%{$reset_color%} "
}
PROMPT='%{$fg[red]%}%n@%m:%{$reset_color%}%{$fg[green]%}%~%{$reset_color%} $(git_prompt_segment)%{$fg[red]%}$%{$reset_color%} '

alias neovim="nvim"

cc() { tmux-claude "${1:-$PWD}"; }

chpwd() { [[ -t 1 ]] && printf '\033]2;%s\033\\' "$PWD"; }

if [[ -z "$TMUX" && -o interactive && -t 1 ]]; then
    exec tmux new-session -A -s main
fi
