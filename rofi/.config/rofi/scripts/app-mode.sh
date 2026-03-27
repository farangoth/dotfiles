#!/bin/env bash
set -e
set -u

ORDER=("web" "file" "editor" "config" "term")
declare -A APPS
APPS=(
    ["web"]="󰖟  web browser"
    ["file"]="  file manager"
    ["editor"]="  text editor"
    ["config"]="  edit config"
    ["term"]="  terminal"
)

declare -A COMMANDS
COMMANDS=(
    ["web"]="firefox --new-tab about:newtab"
    ["file"]="thunar $HOME"
    ["editor"]="kitty -d $HOME nvim"
    ["config"]="kitty -d $HOME/dotfiles/ nvim"
    ["term"]="kitty"
)
if [[ -z "$*" ]]; then
    echo -en "\0prompt\x1fapps \n"
    echo -en "\0markup-rows\x1ftrue\n"
    for entry in "${ORDER[@]}"; do
        printf "<b>%s</b>\t<i><small>(%-s)</small></i>\n" "${APPS[$entry]}" "${COMMANDS[$entry]}"
    done
else
    selection=$(echo "$1" | sed -E 's/<[^>]*>//g' | sed -E 's/.*\((.*)\)/\1/')
    
    if [[ -n "$selection" ]]; then
         nohup bash -c "$selection" >/dev/null 2>&1 &
    fi
fi

        
