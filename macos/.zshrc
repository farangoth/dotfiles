eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon Homebrew prefix; puts
                                            # brewed nvim/tmux/fzf/etc. on PATH

export PATH=$HOME/bin:$HOME/.local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

export EDITOR="nvim"
# No $TERMINAL: nothing on macOS shells out to it the way river/rofi do on
# the desktop.
# No hardcoded SSH_AUTH_SOCK: on macOS this is normally set by whichever SSH
# agent you run (Secretive, 1Password, or ssh-agent via launchd) -- setting
# it here would clobber that, the same class of bug the raspi zshrc already
# avoids for `ssh -A` agent forwarding.

zstyle ':omz:update' mode reminder
ZSH_THEME="macovsky"

export PYTHON_VENV_NAME=".venv"
export PYTHON_AUTO_VRUN=true

plugins=(
	git
	colored-man-pages
	python
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
  echo "%{$fg[yellow]%}< ${ref}${flags:+ $flags} >%{$reset_color%} "
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

# Catppuccin Frappe in iTerm2 for the duration of an SSH session, restored
# to Mocha (the "Default" profile) on exit -- via iTerm2's proprietary OSC 50
# "SetProfile" sequence switching to the "SSH-Frappe" dynamic profile (see
# ~/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json), the
# iTerm2-native equivalent of the desktop's foot-theme script (which reads
# theme files that don't exist on macOS). Also sets the window title to
# "SSH: <target>" (cleared back to empty on exit) as a second, textual
# signal alongside the color switch (Frappe/Mocha are both dark, so the
# color flip alone is subtler than Latte's was). Guarded on -t 1 so neither
# fires when ssh's output is being piped/captured (git remotes, deploy
# scripts, etc.) -- otherwise the escape sequences would land in whatever's
# capturing it. If ssh runs inside tmux, tmux needs `allow-passthrough on`
# and `set-titles on` to forward these through to iTerm2 instead of
# swallowing them (see tmux.conf).
#
# NOT verified against a real iTerm2 session -- built from iTerm2's
# documented OSC 50 SetProfile syntax, not tested live. Confirm the profile
# actually flips (and that allow-passthrough is enough inside tmux) before
# relying on it.
ssh() {
    # Route through tmux-ssh (tmux/.local/bin/tmux-ssh, shared with the
    # desktop package) for a dedicated, reattachable tmux session per
    # target instead of running inline -- mirrors the tmux-dev
    # session-per-context pattern (dev() below just calls tmux-dev
    # directly too, with no new-window spawn -- macOS has no
    # Mod+Return-style "always shows main" window contract to protect the
    # way desktop's zsh/.zshrc does, so there's nothing to guard against
    # here). TMUX_SSH_ACTIVE guards against recursion: tmux-ssh's spawned
    # pane calls this same function again to make the actual connection
    # (so it still gets the theme-switch/title logic below), and without
    # the guard that second call would try to wrap itself in yet another
    # nested tmux-ssh session instead of just connecting.
    #
    # Only wraps ssh when the CURRENT session is `main`, one of tmux's own
    # numbered default sessions ("0", "1", ... -- what you get from a
    # plain `tmux new-session` with no -s), or itself a tmux-ssh session
    # (`ssh-<target>[-N]`) -- all three are either generic/ambient shells
    # or already part of the ssh-session family, so nesting another `ssh`
    # call there should still get tmux-ssh's own session management (e.g.
    # splitting a new pane inside `ssh-raspi` and typing `ssh raspi` again
    # should open an independent `ssh-raspi-2`, not silently join the
    # exact remote session that pane split off from). Any other *named*
    # session (dev-<dir>, ...) is a deliberately scoped workspace
    # unrelated to ssh; ssh typed there should behave like any other
    # command inside it -- plain inline ssh below -- instead of spinning
    # up yet another persistent session on top of it (matches desktop's
    # zsh/.zshrc).
    if [[ -z "${TMUX_SSH_ACTIVE:-}" && -t 1 ]] && (( $+commands[tmux-ssh] )); then
        local current_session=""
        [[ -n "$TMUX" ]] && current_session=$(tmux display-message -p '#S' 2>/dev/null)
        if [[ -z "$TMUX" || "$current_session" == "main" || "$current_session" =~ '^[0-9]+$' || "$current_session" =~ '^ssh-' ]]; then
            tmux-ssh "$@"
            return 0
        fi
        # else: some other named session -- fall through to plain inline
        # ssh below, same as if tmux-ssh weren't installed at all.
    fi
    if [[ -t 1 && "$TERM_PROGRAM" == "iTerm.app" ]]; then
        local target="${@[-1]:-ssh}"  # heuristic: usually the last arg is
                                       # the host, but `ssh host cmd args`
                                       # would show the last arg instead
        printf '\033]2;SSH: %s\033\\' "$target"
        printf '\033]50;SetProfile=SSH-Frappe\a'
        # Also rename the tmux window itself, not just the outer terminal
        # title -- the title is one shared string for the whole terminal,
        # so it doesn't distinguish which tmux window you're looking at.
        # Re-enabling automatic-rename after exit lets it resume tracking
        # the running command as normal; if you'd manually renamed this
        # window yourself before connecting, that manual name is lost.
        [[ -n "$TMUX" ]] && tmux rename-window "ssh:$target"
        command ssh "$@"
        local exit_code=$?
        printf '\033]50;SetProfile=Default\a'
        printf '\033]2;\033\\'
        [[ -n "$TMUX" ]] && tmux set-window-option automatic-rename on
        return $exit_code
    fi
    command ssh "$@"
}

# -- report cwd via the window title, for whoever's ssh'd into this box --
# tmux can only read pane_current_path off its own local pty, so a pane
# running `ssh` always shows wherever `ssh` itself was launched FROM, never
# wherever `cd` takes you on the far end -- there's no way for the local
# tmux to inspect a remote shell's cwd directly. OSC 2 (window title)
# sidesteps that: it's just bytes in the pty stream, so it crosses the ssh
# connection like any other terminal escape sequence and updates the
# *local* pane's title (tmux's pane_title) same as if it came from a local
# program. The status bar's SSH-branch cwd pill reads #{pane_title} instead
# of #{pane_current_path} for exactly this reason (see tmux.conf). Defined
# as a bare `chpwd` (not add-zsh-hook) -- zsh calls any function with that
# exact name automatically on every directory change and once at shell
# startup, no registration needed. Guarded on -t 1 so it doesn't leak
# escape codes into piped/captured output, matching the ssh() function's
# own guard above.
chpwd() { [[ -t 1 ]] && printf '\033]2;%s\033\\' "$PWD"; }

# ---- zoxide (smarter cd) ----
eval "$(zoxide init zsh)"
alias cd="z"          # keep `cd` muscle memory, backed by zoxide's ranking
alias cdi="zi"         # interactive pick via fzf when there are multiple matches

# ---- fzf (fuzzy finder) ----
source <(fzf --zsh)

# Catppuccin Mocha, matching tmux and the iTerm2 "Default" profile
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

dev() { tmux-dev "${1:-$PWD}"; }

# -- always inside tmux -- makes tmux's bindings the only bindings that
# matter, on both this machine and Arch/river (iTerm2/foot otherwise
# diverge on native tab/pane shortcuts neither shares). Skips
# non-interactive shells, anything without a real tty (script/cron
# contexts), and shells already inside tmux (no nesting). `exec`, not a
# plain call, so once the session ends there's no shell left to fall
# back to -- iTerm2's child process just ends, closing the window
# instead of leaving a bare prompt behind (see zsh/.zshrc for the live
# confirmation of exec vs non-exec here). `new-session -A` attaches if
# `main` exists or creates it, atomically.
if [[ -z "$TMUX" && -o interactive && -t 1 ]]; then
    exec tmux new-session -A -s main
fi
