#!/bin/env bash

NOTES_DIR="$HOME/git/gitjournal"
EDITOR="nvim"
TERMINAL="kitty"

mkdir -p "$NOTES_DIR"

CREATE_NEW=" New note"

if [ -z "$*" ]; then
    echo -e "$CREATE_NEW"

    find "$NOTES_DIR" -maxdepth 2 -type f -name *.md -printf '%T@ %P\n' \
        | sort -nr \
        | head -n 5 \
        | cut -d' ' -f2- \
        | sed 's/^/ /'

else
    selection="$1"
    run_cmd=""

    if [ "$selection" == "$CREATE_NEW" ]; then
        new_note_path="$NOTES_DIR/Note_$(date +'%Y-%m-%d-%H:%M').md"
        run_cmd="$TERMINAL $EDITOR '$new_note_path'"
    else
        filename=$(echo "$selection" | sed 's/^..//')
        run_cmd="$TERMINAL $EDITOR '$NOTES_DIR/$filename'"
    fi

    if [ -n "$run_cmd" ]; then
        nohup bash -c "$run_cmd" > /dev/null 2>&1 &
    fi

fi

