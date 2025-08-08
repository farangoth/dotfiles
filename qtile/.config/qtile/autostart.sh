#!/bin/env bash

killall -q swaync
while pgrep -u $UID -x swaync >/dev/null; do sleep 1; done
swaync &
