#!/bin/env bash
mapfile -t COUNTRIES < <(nordvpn countries)
declare -a COUNTRIES

if [[ -z "$*" ]]; then
    for country in "${COUNTRIES[@]}"; do
        echo -e "$country"
    done

else
    selection="$1"
    run_cmd="nordvpn connect $selection"
    nohup bash -c "$run_cmd" > /dev/null 2>&1 &
fi
