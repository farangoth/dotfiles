#!/usr/bin/env bash

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
  
if [[ -z "$*" ]]; then
    echo -en "\0prompt\x1fpower\n"
    echo -en "\0markup-rows\x1ftrue\n"
    # Reject any custom-typed entry outright -- without this, a selection
    # that doesn't match one of our own rows below falls through to the
    # dispatch branch with rofi's raw typed text as $1, which the old
    # sed-extraction dispatch (still used as a fallback below) would have
    # handed straight to `bash -c` if it happened to contain "(...)" --
    # this is defense in depth on top of the safer label-match dispatch.
    echo -en "\0no-custom\x1ftrue\n"
    for entry in "${ORDER[@]}"; do
        printf "<b>%s</b>\t<i><small>(%-s)</small></i>\n" "${ACTIONS[$entry]}" "${CMDS[$entry]}"
    done
else
    # Match the selected row's own label against our known ACTIONS values
    # instead of executing text extracted from inside the row -- $1 is
    # rofi's returned row, and the old approach sed-extracted whatever sat
    # between the last "(...)" and ran THAT via `bash -c`, which is
    # attacker-controlled the moment rofi's dmenu-style matching returns
    # anything that isn't strictly one of our own generated rows. Only
    # ever running one of the fixed CMDS[] strings below closes that off
    # regardless of what $1 actually contains.
    label=$(printf '%s' "$1" | sed -E 's/<[^>]*>//g')
    label="${label%%$'\t'*}"
    for entry in "${ORDER[@]}"; do
        if [[ "$label" == "${ACTIONS[$entry]}" ]]; then
            nohup bash -c "${CMDS[$entry]}" >/dev/null 2>&1 &
            break
        fi
    done
fi
