#!/bin/env bash

get_devices() {
    bluetoothctl devices | grep "^Device" | while read -r line; do
        mac_addr=$(echo "$line" | awk '{print $2}')
        device=$(echo "$line" | cut -d' ' -f3-)
        if bluetoothctl info "$mac_addr" | grep -q "Connected: yes"; then
            status=""
            rofi_meta="blue"
        else
            status="󰂲"
            rofi_meta="urgent"
        fi
        printf "%s\t%s\t%s\0%s\x1ftrue\n" "$status" "$device" "$mac_addr" "$rofi_meta"
    done
    echo "open bluetoothctl CLI"
}

chosen=$(get_devices | rofi -dmenu -p bluetooth)

if [ -z "$chosen" ]; then
    exit 0
fi

state=$(echo "$chosen" | awk '{print $1}')
mac_addr=$(echo "$chosen" | cut -d$'\t' -f3 | cut -c1-17)

case "$state" in
    "")
        bluetoothctl disconnect "$mac_addr"
        ;;
    "󰂲")
        bluetoothctl connect "$mac_addr"
        ;;
    *)
        foot bluetoothctl
        ;;
esac
