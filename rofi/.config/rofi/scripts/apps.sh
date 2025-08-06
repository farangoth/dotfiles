#!/bin/env bash

set -e
set -u

declare -A APPS
APPS=(
    ["web"]="  web browser - firefox"
    ["file"]=" 󰉋 file manager - thunar"
    ["editor"]=" 󰭷 editor - nvim"
    ["notes"]="  edit notes"
    ["code"]="  edit code"
    ["config"]="  edit config - dotfiles"
    ["term"]="  open terminal - foot"
)

declare -A COMMANDS
COMMANDS=(
    ["web"]="firefox --new-tab about:newtab & sleep 0.2 && qtile cmd-obj -o group 3 -f toscreen" 
    ["file"]="thunar"
    ["editor"]="foot nvim ~ +:Neotree"
    ["notes"]="foot nvim git/gitjournal/ :Neotree" 
    ["code"]="foot nvim code/ +:Neotree"
    ["config"]="foot nvim dotfiles/ +:Neotree"
    ["term"]="foot"
)
if [ -z "$*" ]; then
    for entry in "${!APPS[@]}"; do
        echo -e "${APPS[$entry]}"
    done
else
    selection="$1"
    run_cmd=""

    for entry in "${!APPS[@]}"; do
        if [ "$selection" == "${APPS[$entry]}" ]; then
            run_cmd="${COMMANDS[$entry]}"
            break
        fi
    done

    nohup bash -c "$run_cmd" > /dev/null 2>&1 &
fi

