#!/bin/env bash

TERMINAL="kitty"
STATION="wlan0"
PROMPT="󰖩 WiFi"

get_status() {
    iwctl station "$STATION" show | grep -E "Connected network|State" | awk '{print $NF}'
}

get_networks() {
    iwctl station "$STATION" scan
    iwctl station "$STATION" get-networks | sed -e $'s/\e\\[[0-9;]*[a-zA-Z]//g' -e '1,4d' | while read -r line; do
        is_connected=$(echo "$line" | grep -o ">")
        network_name=$(echo "$line" | sed 's/^[* >]*//' | awk '{print $1}')
        security=$(echo "$line" | awk '{print $NF}')
        
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

CHOSEN=$(get_networks | rofi -dmenu -i -p "$PROMPT" -markup-rows)

if [[ -z "$CHOSEN" ]]; then
    exit 0
fi

if [[ "$CHOSEN" == " iwctl CLI" ]]; then
    $TERMINAL iwctl
fi

if [[ "$CHOSEN" == "󰑐 Rescan" ]]; then
    exec "$0"
fi

NETWORK=$(echo "$CHOSEN" | sed -E 's/^[^ ]+ +//; s/ +\(.*\)$//')

notify-send "Connecting to $NETWORK..."

if iwctl station "$STATION" connect "$NETWORK"; then
    notify-send "󰖩 Connected to $NETWORK"
else
    notify-send -u critical "Failed to connect to $NETWORK" "If a password is required, try: iwctl station $STATION connect $NETWORK"
fi
