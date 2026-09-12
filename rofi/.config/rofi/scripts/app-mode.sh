#!/bin/env bash
set -e
set -u

ORDER=("web" "file" "editor" "config" "term" "theme" "wifi" "bluetooth")
declare -A APPS
APPS=(
    ["web"]="󰖟  web browser"
    ["file"]="  file manager"
    ["editor"]="  text editor"
    ["config"]="  edit config"
    ["term"]="  terminal"
    ["theme"]="󰏘  theme"
    ["wifi"]="󰖩  wifi"
    ["bluetooth"]="  bluetooth"
)

declare -A COMMANDS
COMMANDS=(
    ["web"]="firefox --new-tab about:newtab"
    ["file"]="thunar $HOME"
    ["editor"]="foot -D $HOME nvim"
    ["config"]="foot -D $HOME/dotfiles/ nvim"
    ["term"]="foot"
    ["theme"]="nwg-look"
    ["wifi"]="$HOME/.config/rofi/scripts/wifi.sh"
    ["bluetooth"]="$HOME/.config/rofi/scripts/bluetooth.sh"
)
# `(( $# == 0 ))`, not `[[ -z "$*" ]]` -- see power-grid.sh for why.
if (( $# == 0 )); then
    echo -en "\0prompt\x1fapps \n"
    echo -en "\0markup-rows\x1ftrue\n"
    for entry in "${ORDER[@]}"; do
        printf "<b>%s</b>\t<i><small>(%-s)</small></i>\n" "${APPS[$entry]}" "${COMMANDS[$entry]}"
    done
else
    selection=$(echo "$1" | sed -E 's/<[^>]*>//g' | sed -E 's/.*\((.*)\)/\1/')

    if [[ -n "$selection" ]]; then
         nohup bash -c "$selection" >/dev/null 2>&1 &
    fi
fi
