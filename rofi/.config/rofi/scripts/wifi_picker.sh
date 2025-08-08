#!/bin/env bash
station="wlan0"
if ! scan_output=$(iwctl station "$station" scan 2>&1) ; then
    echo -e "Error! Failed to scan ${station}"
    echo -e "Detail: $scan_output"
fi

networks=$(iwctl station ${station} get-networks | sed -e $'s/\e\\[[0-9;]*[a-zA-Z]//g' -e '1,4d' -e 's/^[[:space:]]*>[[:space:]]*//')
chosen=$(echo -e "$networks" | rofi -dmenu -p "wifi" -i)

if [ -z "$chosen" ]; then
    exit 0
fi

security=$(echo "$chosen" | awk '{for (i=1; i<=NF; i++) if ($i ~ /^[*]+$/) {print $(i-1); exit}}')
ssid=$(echo "$chosen" | sed -E "s/\s+$security\s+.*//" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')


case "$security" in
    "open")
        iwctl station "$station" connect "$ssid"
        notify-send "󰖩  Wifi connection" "${ssid} (open)"
        ;;
    "psk"|"sae")
        known_networks=$(iwctl known-networks list | sed -e $'s/\e\\[[0-9;]*[a-zA-Z]//g' -e '1,4d' -e 's/\s+\S+\s+\S+$//')
        if echo "$known_networks" | grep -qF "$ssid"; then
            iwctl station "$station" connect "$ssid"
            notify-send "󰖩  Wifi connection" "${ssid} (known)"
        else
            password=$(rofi -dmenu -password -p "Pass for \"$ssid\"")

            if [ -n "$password" ]; then
                iwctl stations "$station" connect "$ssid" --passphrase "$password"
                notify-send "󰖩  Wifi connection" "${ssid} (attempt)"
            else
                exit 0
            fi
        fi
        ;;
    *)
        notify-send "Impossible to connect" "Unknown ${ssid}"
        exit 1;
esac
