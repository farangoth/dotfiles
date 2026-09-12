#!/bin/env bash

set -e
set -u

ORDER=("lock" "kill" "suspend" "reboot" "shutdown")

declare -A ICONS
ICONS=(
    ["lock"]=""
    ["kill"]="󰈆"
    ["suspend"]="󰒲"
    ["reboot"]=""
    ["shutdown"]="󰐥"
    )

declare -A CMDS
CMDS=(
    ["lock"]="swaylock"
    ["kill"]="riverctl exit"
    ["suspend"]="systemctl suspend"
    ["reboot"]="systemctl reboot"
    ["shutdown"]="systemctl power-off"
    )
  
# `(( $# == 0 ))`, not `[[ -z "$*" ]]` -- the latter can't distinguish "no
# arguments" from "one argument that happens to be an empty string", which
# rofi passes back on some selection paths; that collapse re-rendered the
# menu instead of dispatching the command.
if (( $# == 0 )); then
    echo -en "\0markup-rows\x1ftrue\n"
    for entry in "${ORDER[@]}"; do
        echo -en "${ICONS[$entry]}\n"
    done
else
    selection="$1"
    run_cmd=""
    for key in "${ORDER[@]}"; do
        if [[ "$selection" == "${ICONS[$key]}" ]]; then
            run_cmd="${CMDS[$key]}"
            break
        fi
    done 
    if [[ -n "$run_cmd" ]]; then
        nohup bash -c "$run_cmd" >/dev/null 2>&1 &
    fi
fi
