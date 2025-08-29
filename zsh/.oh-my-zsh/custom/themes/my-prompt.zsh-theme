autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red}*' 
zstyle ':vcs_info:*' stagedstr '%F{yellow}+'
zstyle ':vcs_info:*' branchformat '%b'
zstyle ':vcs_info:*' actionformats '%F{5}[ %b%F{3}|%F{1}%a%c%u%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{#a5adcb} %b%f%c%u%f '
zstyle ':vcs_info:*' enable git
theme_precmd() {
    vcs_info
}

virtualenv_prompt () {
    if [[ -n ${VIRTUAL_ENV} ]]; then
        local venv_path=$(dirname "$VIRTUAL_ENV")
        local venv_name=$(basename "$venv_path")
        echo -n "%F{yellow} $venv_name%f"
    fi
}

retval_prompt () {
    RETVAL=$?
    if [[ $RETVAL -ne 0 ]]; then
        echo -n "%F{red} $RETVAL%f"
    fi
}

setopt promptsubst
NEWLINE=$'\n'
TAB=$'\t'
PROMPT='$NEWLINE %B%F{blue}%~%b%f$TAB ${vcs_info_msg_0_}$TAB  $(virtualenv_prompt)$NEWLINE > '
RPROMPT='$(retval_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd
