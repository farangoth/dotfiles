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

# -- git and zsh --
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
PROMPT='%{$fg[green]%}%~%{$reset_color%} $(ruby_prompt_info) $(git_prompt_segment)%{$reset_color%}%B$%b '

# auto-fetch
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

# -- conditional theme on ssh --
ssh() {
    if [[ -t 1 ]] && (( $+commands[foot-theme] )); then
        local target="${@[-1]:-ssh}"
        printf '\033]2;SSH: %s\033\\' "$target"
        foot-theme frappe
        # Also rename the tmux window itself, not just the outer terminal
        # title -- the title is one shared string for the whole terminal,
        # so it doesn't distinguish which tmux window you're looking at.
        # Re-enabling automatic-rename after exit lets it resume tracking
        # the running command as normal; if you'd manually renamed this
        # window yourself before connecting, that manual name is lost.
        [[ -n "$TMUX" ]] && tmux rename-window "ssh:$target"
        command ssh "$@"
        local exit_code=$?
        foot-theme reset
        printf '\033]2;\033\\'
        [[ -n "$TMUX" ]] && tmux set-window-option automatic-rename on
        return $exit_code
    fi
    command ssh "$@"
}

# ---- zoxide (smarter cd) ----
eval "$(zoxide init zsh)"
alias cd="z" 
alias cdi="zi"

# ---- fzf (fuzzy finder) ----
source <(fzf --zsh)

# Catppuccin Mocha, matching foot/tmux/rofi/waybar
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline \
--color=fg:#cdd6f4,fg+:#cdd6f4,bg:#1e1e2e,bg+:#313244 \
--color=hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,marker:#f5e0dc \
--color=prompt:#cba6f7,spinner:#f5e0dc,pointer:#f5e0dc,header:#f38ba8 \
--color=border:#313244,label:#cdd6f4,query:#cdd6f4"

_fzf_preview='[[ -d {} ]] && eza --tree --level=2 --color=always --icons=auto {} || bat --color=always --style=numbers --line-range=:200 {}'

# Ctrl-T / Alt-C -- explicit fzf invocation, full window + preview
export FZF_CTRL_T_OPTS="--height=100% --preview=\"$_fzf_preview\" --preview-window=right:60%:wrap"
export FZF_ALT_C_OPTS="--height=100% --preview='eza --tree --level=2 --color=always --icons=auto {}' --preview-window=right:60%"

# ---- eza (ls replacement) ----
alias ls="eza --icons=never --group-directories-first"
alias ll="eza --icons=never --group-directories-first --git -l"
alias la="eza --icons=never --group-directories-first --git -la"
alias lt="eza --icons=never --group-directories-first --git --tree --level=2"

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

# -- aliases --
alias neovim="nvim"
# Spawns a new foot window rather than running tmux-dev inline: tmux-dev
# ends by attaching/switching the CALLING client to the dev-<dir> session,
# so running it in the current shell would hijack whatever window you
# typed `dev` in -- including the term-main window Mod+Return manages,
# switching it away from `main` and breaking that binding's "always shows
# main" contract. A fresh, untagged window sidesteps that entirely: it
# gets its own tmux client, so the window you launched `dev` from keeps
# showing whatever it was already showing. Subshell-backgrounded (same
# job-control-message-suppression trick as the git-fetch hook above)
# rather than `&` directly, so no `[1] <pid>` / `[1]+ Done` noise lands in
# the calling shell.
dev() { ( foot tmux-dev "${1:-$PWD}" & ) 2>/dev/null; }

# -- always inside tmux -- makes tmux's bindings the only bindings that
# matter, on both this machine and macOS (iTerm2/foot otherwise diverge on
# native tab/pane shortcuts neither shares). Skips non-interactive shells,
# anything without a real tty (script/cron contexts), and shells already
# inside tmux (no nesting). `exec` (not a plain call) so that once the
# session ends -- its last window closed, which already destroys the
# session by itself -- there's no shell left for control to fall back to:
# the terminal's child process just ends, closing the window instead of
# leaving a bare prompt behind. Confirmed live: without exec, a wrapper
# shell resumes after tmux exits (real output observed); with exec, it
# doesn't -- nothing runs after tmux exits, because there's no process
# left to run it. `new-session -A` attaches if `main` exists or creates
# it otherwise, in one atomic command instead of two (no window where the
# first `tmux attach` has already failed but the second `tmux new` hasn't
# run yet, which could race a second shell doing the same thing into
# creating a duplicate session).
if [[ -z "$TMUX" && -o interactive && -t 1 ]]; then
    exec tmux new-session -A -s main
fi
