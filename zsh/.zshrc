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
    fzf-tab
)

source $HOME/.env_secrets
source $ZSH/oh-my-zsh.sh

# ---- extend macovsky's git segment: dirty state + ahead/behind vs upstream,
# all inside one <branch +> bracket, plain ASCII only (+ ahead, - behind,
# * dirty). Reads local refs only (no network) -- ahead/behind reflect
# whatever the last `git fetch` last saw, not a live check.
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
  echo "%{$fg[yellow]%}<${ref}${flags:+ $flags} >%{$reset_color%} "
}
PROMPT='%{$fg[green]%}%~%{$reset_color%} $(ruby_prompt_info) $(git_prompt_segment)%{$reset_color%}%B$%b '

# Throttled background `git fetch` so the "-" (behind) flag above catches up
# on its own instead of only reflecting whatever the last manual fetch saw.
# Runs at most once every 5 min per repo, in the background, off stdin, so it
# never blocks the prompt and fails silently (no network, no cached creds)
# rather than hanging on a credential prompt.
zmodload zsh/datetime
autoload -Uz add-zsh-hook
typeset -gA _git_prompt_last_fetch
function _git_prompt_maybe_fetch() {
  local toplevel
  toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || return
  local now=$EPOCHSECONDS
  local last=${_git_prompt_last_fetch[$toplevel]:-0}
  (( now - last < 300 )) && return
  _git_prompt_last_fetch[$toplevel]=$now
  ( git fetch --quiet </dev/null &>/dev/null & ) 2>/dev/null
}
add-zsh-hook precmd _git_prompt_maybe_fetch

alias neovim="nvim"

# Catppuccin Frappe in foot for the duration of an SSH session, restored
# to whatever foot.ini loaded (Mocha) on exit -- see
# ~/.local/bin/foot-theme. Also sets the window title to "SSH: <target>"
# (cleared back to empty on exit) -- waybar's river/window module shows
# the title live, so this is a second, textual signal alongside the color
# switch (Frappe/Mocha are both dark, so the color flip alone is
# subtler than Latte's was). Guarded on -t 1 so neither fires when ssh's
# output is being piped/captured (git remotes, deploy scripts, etc.) --
# otherwise the escape sequences would land in whatever's capturing it.
# If ssh runs inside tmux, tmux needs `allow-passthrough on` (for
# foot-theme) and `set-titles on` (for the title) to forward these
# through to foot instead of swallowing them (see tmux.conf).
ssh() {
    if [[ -t 1 ]] && (( $+commands[foot-theme] )); then
        local target="${@[-1]:-ssh}"  # heuristic: usually the last arg is
                                       # the host, but `ssh host cmd args`
                                       # would show the last arg instead
        printf '\033]2;SSH: %s\033\\' "$target"
        foot-theme frappe
        command ssh "$@"
        local exit_code=$?
        foot-theme reset
        printf '\033]2;\033\\'
        return $exit_code
    fi
    command ssh "$@"
}

# ---- zoxide (smarter cd) ----
eval "$(zoxide init zsh)"
alias cd="z"          # keep `cd` muscle memory, backed by zoxide's ranking
alias cdi="zi"         # interactive pick via fzf when there are multiple matches

# ---- fzf (fuzzy finder) ----
source <(fzf --zsh)

# Catppuccin Mocha, matching foot/tmux/rofi/waybar
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline \
--color=fg:#cdd6f4,fg+:#cdd6f4,bg:#1e1e2e,bg+:#313244 \
--color=hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,marker:#f5e0dc \
--color=prompt:#cba6f7,spinner:#f5e0dc,pointer:#f5e0dc,header:#f38ba8 \
--color=border:#313244,label:#cdd6f4,query:#cdd6f4"

_fzf_preview='[[ -d {} ]] && eza --tree --level=2 --color=always --icons=auto {} || bat --color=always --style=numbers --line-range=:200 {}'

# **<Tab> path completion -- inherits the small 40% height above, no preview
# export FZF_COMPLETION_OPTS left unset on purpose

# Ctrl-T / Alt-C -- explicit fzf invocation, full window + preview
export FZF_CTRL_T_OPTS="--height=100% --preview=\"$_fzf_preview\" --preview-window=right:60%:wrap"
export FZF_ALT_C_OPTS="--height=100% --preview='eza --tree --level=2 --color=always --icons=auto {}' --preview-window=right:60%"

# ---- eza (ls replacement) ----
alias ls="eza --icons=never --group-directories-first"
alias ll="eza --icons=auto --group-directories-first --git -l"
alias la="eza --icons=auto --group-directories-first --git -la"
alias lt="eza --icons=auto --group-directories-first --git --tree --level=2"

# ---- native zsh completion settings fzf-tab expects ----
zstyle ':completion:*' menu no                          # let fzf-tab take over, don't fight it with the default menu
zstyle ':completion:*:descriptions' format '[%d]'        # group headers in the popup
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # colorize entries using LS_COLORS

# ---- fzf-tab itself: small popup, no preview (see FZF_CTRL_T_OPTS/
# FZF_ALT_C_OPTS from earlier for the full+preview case) ----
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger '/'

# optional: lightweight (non-bat) preview just for cd completion
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
