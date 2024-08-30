#! /bin/sh

export DISPLAY=":0"
#export XAUTHORITY="/home/${USER_NAME}/.Xauthority" # for sddm
export XAUTHORITY="/run/user/1000/lyxauth" # for ly

USER_NAME=$(id -un)
USER_ID=$(id -u)

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${USER_ID}/bus"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $USER_ID -x polybar >/dev/null; do sleep 1; done

# Launch polybar on each monitor
polybar --list-monitors | cut -d":" -f1 |
while read -r monitor; do
  if [ "$(xrandr -q | grep -e "\sconnected\s" | grep $monitor | grep -c primary)" == "1" ]; then
    MONITOR=$monitor polybar top -c /home/${USER_NAME}/.config/polybar/config.ini &
  else
    MONITOR=$monitor polybar top-no-tray -c /home/${USER_NAME}/.config/polybar/config.ini &
  fi

  MONITOR=$monitor polybar main -c /home/${USER_NAME}/.config/polybar/config.ini &
done

