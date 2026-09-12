#!/usr/bin/env bash
# Matches the -e/-u convention the other rofi scripts in this package use
# (power-mode.sh, power-grid.sh, app-mode.sh) -- no pipefail, since several
# pipelines here intentionally tolerate a failing first stage (rofi being
# cancelled, iwctl returning non-zero) and are guarded explicitly below
# rather than relying on pipefail's stricter, harder-to-verify propagation
# through multi-stage pipes.
set -e
set -u

TERMINAL="foot"
STATION="wlan0"
PROMPT="󰖩 WiFi"

get_networks() {
    # A scan already in progress can make some iwctl versions return
    # non-zero here even though scanning still proceeds fine -- best-effort
    # under set -e, so it doesn't abort the whole picker over that.
    iwctl station "$STATION" scan || true
    iwctl station "$STATION" get-networks | sed -e $'s/\e\\[[0-9;]*[a-zA-Z]//g' -e '1,4d' | while read -r line; do
        # Herestrings instead of `echo "$line" | ...` -- same output, one
        # fewer forked process per field per line.
        is_connected=$(grep -o ">" <<< "$line" || true)
        # Pure bash instead of `sed 's/^[* >]*//' | awk '{print $1}'` --
        # one regex match instead of two forked processes for the same
        # "strip the leading */>/space marker, take the first field" job.
        if [[ "$line" =~ ^[*\ \>]*([^[:space:]]+) ]]; then
            network_name="${BASH_REMATCH[1]}"
        else
            network_name=""
        fi
        security=$(awk '{print $NF}' <<< "$line")

        if [[ -n "$is_connected" ]]; then
            icon="󰖩"
            meta="active"
        else
            icon="󰖪"
            meta="normal"
        fi
        
        printf "%s %-20.20s\t(%s)\0%s\x1ftrue\n" "$icon" "$network_name" "$security" "$meta"
    done
    echo "󰑐 Rescan"
    echo " iwctl CLI"
}

# `|| true`: rofi exits non-zero on cancel (Escape) -- without it, `set -e`
# would abort the script right here instead of reaching the `-z "$CHOSEN"`
# graceful-exit check just below.
CHOSEN=$(get_networks | rofi -dmenu -i -p "$PROMPT" -markup-rows) || true

if [[ -z "$CHOSEN" ]]; then
    exit 0
fi

if [[ "$CHOSEN" == " iwctl CLI" ]]; then
    $TERMINAL iwctl
fi

if [[ "$CHOSEN" == "󰑐 Rescan" ]]; then
    exec "$0"
fi

NETWORK=$(sed -E 's/^[^ ]+ +//; s/ +\(.*\)$//' <<< "$CHOSEN")

notify-send "Connecting to $NETWORK..."

if iwctl station "$STATION" connect "$NETWORK"; then
    notify-send "󰖩 Connected to $NETWORK"
else
    notify-send -u critical "Failed to connect to $NETWORK" "If a password is required, try: iwctl station $STATION connect $NETWORK"
fi
