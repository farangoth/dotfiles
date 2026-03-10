#!/bin/env bash

terminal="kitty"

get_devices() {
    bluetoothctl devices | grep "^Device" | while read -r line; do
        mac_addr=$(echo "$line" | awk '{print $2}')
        device=$(echo "$line" | cut -d' ' -f3-)
        if bluetoothctl info "$mac_addr" | grep -q "Connected: yes"; then
            state=""
            rofi_meta="blue"
        else
            state="󰂲"
            rofi_meta="urgent"
        fi
        printf "%s\t%s\t%s\0%s\x1ftrue\n" "$state" "$device" "$mac_addr" "$rofi_meta"
    done
    echo "bluetooth CLI"
}

chosen=$(get_devices | rofi -dmenu -p bluetooth)

if [ -z "$chosen" ]; then
    exit 0
fi

device=$(echo "$chosen")
state=$(echo "$chosen" | awk '{print $1}')
mac_addr=$(echo "$chosen" | cut -d$'\t' -f3)

case "$state" in
    "")
        notify-send "󰂲 disconnecting..."
        if bluetoothctl disconnect "$mac_addr"; then
            notify-send "󰂲 disconnected"
        else
            notify-send -u critical "󰂲 failed to disconnect"
        fi
        ;;
    "󰂲")
        notify-send " Connecting..."
        if bluetoothctl disconnect "$mac_addr"; then
            notify-send " connected"
        else
            notify-send -u critical " failed to connect"
        fi
        ;;
    *)
        $terminal bluetoothctl 
        ;;
esac
