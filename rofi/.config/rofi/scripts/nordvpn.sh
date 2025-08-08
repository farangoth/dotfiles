#!/bin/env bash
mapfile -t COUNTRIES < <(nordvpn countries)
declare -a COUNTRIES

nordvpn_status=$(nordvpn status)

if [[ -z "$*" ]]; then
    if [[ "$nordvpn_status" == *"Disconnected"* ]]; then
        echo "Auto connect"
    else
        echo "Disconnect"
    fi

    for country in "${COUNTRIES[@]}"; do
        echo -e "$country"
    done
else
    selection="$1"
    run_cmd=""
    if [ "$selection" == "Auto connect" ]; then
        run_cmd="nordvpn connect"
    elif [ "$selection" == "Disconnect" ]; then
        run_cmd="nordvpn disconnect"
    else
        run_cmd="nordvpn connect $selection"
    fi
    nohup bash -c "$run_cmd" > /dev/null 2>&1 &
fi
