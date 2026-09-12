#!/bin/env bash

set -e
set -u

ORDER=("lock" "kill" "suspend" "reboot" "shutdown")
declare -A ACTIONS
ACTIONS=(
    ["lock"]=" lock screen"
    ["kill"]="󰈆 kill session"
    ["suspend"]="󰒲 suspend"
    ["reboot"]=" reboot"
    ["shutdown"]="󰐥 shutdown"
    )

declare -A CMDS
CMDS=(
    ["lock"]="swaylock"
    ["kill"]="riverctl exit"
    ["suspend"]="systemctl suspend"
    ["reboot"]="systemctl reboot"
    ["shutdown"]="systemctl power-off"
    )
  
# `(( $# == 0 ))`, not `[[ -z "$*" ]]` -- see power-grid.sh for why.
if (( $# == 0 )); then
    echo -en "\0prompt\x1fpower\n"
    echo -en "\0markup-rows\x1ftrue\n"
    for entry in "${ORDER[@]}"; do
        printf "<b>%s</b>\t<i><small>(%-s)</small></i>\n" "${ACTIONS[$entry]}" "${CMDS[$entry]}"
    done
else
    selection=$(echo "$1" | sed -E 's/<[^>]*>//g' | sed -E 's/.*\((.*)\)/\1/')

    if [[ -n "$selection" ]]; then
        nohup bash -c "$selection" >/dev/null 2>&1 &
    fi
fi
