#! /bin/sh

echo "Starting polybar"

export DISPLAY=":0"
#export XAUTHORITY="/home/${USER_NAME}/.Xauthority" # for sddm
export XAUTHORITY="/run/user/1000/lyxauth" # for ly

USER_NAME=$(id -un)
USER_ID=$(id -u)

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${USER_ID}/bus"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar on each monitor
polybar --list-monitors | cut -d":" -f1 | while read -r monitor; do
      MONITOR=$monitor polybar top -c ~/.config/polybar/config.ini &
  MONITOR=$monitor polybar main -c ~/.config/polybar/config.ini &
done

