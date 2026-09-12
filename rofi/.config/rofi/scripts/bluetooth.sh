#!/usr/bin/env bash
# Matches the -e/-u convention the other rofi scripts in this package use
# (power-mode.sh, power-grid.sh, app-mode.sh, wifi.sh) -- no pipefail, see
# wifi.sh for why.
set -e
set -u

terminal="foot"
prompt=" bluetooth"

get_devices() {
    bluetoothctl devices | grep "^Device" | while read -r line; do
        # Herestrings instead of `echo "$line" | ...` -- same output, one
        # fewer forked process per field per line.
        mac_addr=$(awk '{print $2}' <<< "$line")
        device=$(cut -d' ' -f3- <<< "$line")
        if bluetoothctl info "$mac_addr" | grep -q "Connected: yes"; then
            state=""
            rofi_meta="active"
        else
            state="󰂲"
            rofi_meta="normal"
        fi
        printf "%s %-20.20s \t(%s)\0%s\x1ftrue\n" "$state" "$device" "$mac_addr" "$rofi_meta"
    done
    echo " bluetooth CLI"
}

# `|| true`: rofi exits non-zero on cancel (Escape) -- without it, `set -e`
# would abort the script right here instead of reaching the `-z "$chosen"`
# graceful-exit check just below.
chosen=$(get_devices | rofi -dmenu -i -p "$prompt" -markup-rows) || true

if [[ -z "$chosen" ]]; then
    exit 0
fi

device=$(cut -d$'\t' -f2 <<< "$chosen" | sed -E 's/^[^[:alpha:]]+//; s/ [0-9A-F:]{17}$//')
state=$(awk '{print $1}' <<< "$chosen")
mac_addr=$(cut -d$'\t' -f3 <<< "$chosen")

case "$state" in
    "")
        notify-send "󰂲 disconnecting $device..."
        if bluetoothctl disconnect "$mac_addr"; then 
            notify-send "󰂲 $device disconnected"
        else
            notify-send -u critical "󰂲 failed to disconnect $device"
        fi
        ;;
    "󰂲")
        notify-send " connecting $device..."
        if bluetoothctl connect "$mac_addr"; then
            # `|| true`: not every device reports a battery percentage --
            # under set -e, grep finding nothing here would otherwise abort
            # the script right after a successful connect.
            batteryinfo=$(bluetoothctl info "$mac_addr" | grep "Battery Percentage" || true)
            notify-send " $device connected" "$batteryinfo"
        else
            notify-send -u critical " failed to connect $device"
        fi
        ;;
    *)
        $terminal bluetoothctl 
        ;;
esac
