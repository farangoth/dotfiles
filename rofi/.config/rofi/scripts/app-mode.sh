#!/usr/bin/env bash
set -e
set -u

ORDER=("web" "file" "editor" "config" "term")
declare -A APPS
APPS=(
    ["web"]="󰖟  web browser"
    ["file"]="  file manager"
    ["editor"]="  text editor"
    ["config"]="  edit config"
    ["term"]="  terminal"
)

declare -A COMMANDS
COMMANDS=(
    ["web"]="firefox --new-tab about:newtab"
    ["file"]="thunar $HOME"
    ["editor"]="foot -D $HOME nvim"
    ["config"]="foot -D $HOME/dotfiles/ nvim"
    ["term"]="foot"
)
if [[ -z "$*" ]]; then
    echo -en "\0prompt\x1fapps \n"
    echo -en "\0markup-rows\x1ftrue\n"
    # Reject any custom-typed entry outright -- see power-mode.sh for why
    # this matters alongside the label-match dispatch below.
    echo -en "\0no-custom\x1ftrue\n"
    for entry in "${ORDER[@]}"; do
        printf "<b>%s</b>\t<i><small>(%-s)</small></i>\n" "${APPS[$entry]}" "${COMMANDS[$entry]}"
    done
else
    # Match the selected row's own label against our known APPS values
    # instead of executing text extracted from inside the row -- see
    # power-mode.sh for the full rationale (the old sed-extraction
    # dispatch ran whatever sat between "(...)" via `bash -c`, which is
    # attacker-controlled the moment $1 isn't strictly one of our own
    # generated rows).
    label=$(printf '%s' "$1" | sed -E 's/<[^>]*>//g')
    label="${label%%$'\t'*}"
    for entry in "${ORDER[@]}"; do
        if [[ "$label" == "${APPS[$entry]}" ]]; then
            nohup bash -c "${COMMANDS[$entry]}" >/dev/null 2>&1 &
            break
        fi
    done
fi
