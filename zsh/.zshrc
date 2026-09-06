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

alias neovim="nvim"

# Catppuccin Frappe in foot for the duration of an SSH session, restored
# to whatever foot.ini loaded (Macchiato) on exit -- see
# ~/.local/bin/foot-theme. Also sets the window title to "SSH: <target>"
# (cleared back to empty on exit) -- waybar's river/window module shows
# the title live, so this is a second, textual signal alongside the color
# switch (Frappe/Macchiato are both dark, so the color flip alone is
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

# Catppuccin Macchiato, matching foot/tmux/rofi/waybar
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline \
--color=fg:#cad3f5,fg+:#cad3f5,bg:#24273a,bg+:#363a4f \
--color=hl:#ed8796,hl+:#ed8796,info:#c6a0f6,marker:#f4dbd6 \
--color=prompt:#c6a0f6,spinner:#f4dbd6,pointer:#f4dbd6,header:#ed8796 \
--color=border:#363a4f,label:#cad3f5,query:#cad3f5"

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
