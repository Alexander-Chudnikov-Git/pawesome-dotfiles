#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar --list-monitors | while IFS=$'\n' read line; do
  if [[ $line == *"(primary)"* ]]; then
    monitor=$(echo $line | cut -d':' -f1)
    MONITOR=$monitor polybar main -c ~/.config/polybar/config.ini &
    MONITOR=$monitor polybar top -c ~/.config/polybar/config.ini &
  fi
done
