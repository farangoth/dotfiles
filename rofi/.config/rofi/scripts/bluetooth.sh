#!/bin/env bash

terminal="foot"
prompt=" bluetooth"

get_devices() {
    bluetoothctl devices | grep "^Device" | while read -r line; do
        mac_addr=$(echo "$line" | awk '{print $2}')
        device=$(echo "$line" | cut -d' ' -f3-)
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

chosen=$(get_devices | rofi -dmenu -i -p "$prompt" -markup-rows)

if [ -z "$chosen" ]; then
    exit 
fi

device=$(echo "$chosen" | cut -d$'\t' -f2 | sed -E 's/^[^[:alpha:]]+//; s/ [0-9A-F:]{17}$//')
state=$(echo "$chosen" | awk '{print $1}')
mac_addr=$(echo "$chosen" | cut -d$'\t' -f3)

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
            batteryinfo=$(bluetoothctl info "$mac_addr" | grep "Battery Percentage")
            notify-send " $device connected" "$batteryinfo"
        else
            notify-send -u critical " failed to connect $device"
        fi
        ;;
    *)
        $terminal bluetoothctl 
        ;;
esac
