#!/bin/sh

run_detached() {
    local monitor="$1"
    local command="$2"
    [ -z "$command" ] && return 1
    echo "$monitor $command"
    MONITOR=$monitor nohup sh -c "$command" </dev/null >/dev/null 2>&1 &
    #disown
}

export DISPLAY=":0"
#export XAUTHORITY="/home/${USER_NAME}/.Xauthority" # for sddm
export XAUTHORITY="/run/user/1000/lyxauth" # for ly

USER_NAME=$(id -un)
USER_ID=$(id -u)

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${USER_ID}/bus"

killall -q polybar

for i in $(seq 1 10); do
    if ! pgrep -u "$USER_ID" -x polybar >/dev/null; then
        break
    fi
    sleep 1
done

polybar --list-monitors | cut -d":" -f1 | while read -r monitor; do
    if xrandr -q | grep -wq "$monitor connected primary"; then
        run_detached "$monitor" "polybar top -c \"/home/${USER_NAME}/.config/polybar/config.ini\""
    else
        run_detached "$monitor" "polybar top-no-tray -c \"/home/${USER_NAME}/.config/polybar/config.ini\""
    fi

    run_detached "$monitor" "polybar main -c \"/home/${USER_NAME}/.config/polybar/config.ini\""
done

