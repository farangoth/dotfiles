#!/bin/bash

volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

if [[ "$volume_info" == *"MUTED"* ]]; then
  echo "0%"
else
  echo "$volume_info" | awk '{printf "%.0f%", $2 * 100}'
fi
