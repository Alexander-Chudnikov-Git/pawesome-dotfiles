#! /bin/sh

# ╔════════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                                                                            ║
# ║   .S_sSSs     .S_SSSs     .S     S.     sSSs    sSSs    sSSs_sSSs     .S_SsS_S.     sSSs   ║
# ║  .SS~YS%%b   .SS~SSSSS   .SS     SS.   d%%SP   d%%SP   d%%SP~YS%%b   .SS~S*S~SS.   d%%SP   ║
# ║  S%S   `S%b  S%S   SSSS  S%S     S%S  d%S'    d%S'    d%S'     `S%b  S%S `Y' S%S  d%S'     ║
# ║  S%S    S%S  S%S    S%S  S%S     S%S  S%S     S%|     S%S       S%S  S%S     S%S  S%S      ║
# ║  S%S    d*S  S%S SSSS%S  S%S     S%S  S&S     S&S     S&S       S&S  S%S     S%S  S&S      ║
# ║  S&S   .S*S  S&S  SSS%S  S&S     S&S  S&S_Ss  Y&Ss    S&S       S&S  S&S     S&S  S&S_Ss   ║
# ║  S&S_sdSSS   S&S    S&S  S&S     S&S  S&S~SP  `S&&S   S&S       S&S  S&S     S&S  S&S~SP   ║
# ║  S&S~YSSY    S&S    S&S  S&S     S&S  S&S       `S*S  S&S       S&S  S&S     S&S  S&S      ║
# ║  S*S         S*S    S&S  S*S     S*S  S*b        l*S  S*b       d*S  S*S     S*S  S*b      ║
# ║  S*S         S*S    S*S  S*S  .  S*S  S*S.      .S*P  S*S.     .S*S  S*S     S*S  S*S.     ║
# ║  S*S         S*S    S*S  S*S_sSs_S*S   SSSbs  sSS*S    SSSbs_sdSSS   S*S     S*S   SSSbs   ║
# ║  S*S         SSS    S*S  SSS~SSS~S*S    YSSP  YSS'      YSSP~YSSY    SSS     S*S    YSSP   ║
# ║  SP                 SP                                                       SP            ║
# ║  Y    ARCH THEME    Y     MADE BY CHOOI    admin@redline-software.moscow     Y             ║
# ║                                                                                            ║
# ╚════════════════════════════════════════════════════════════════════════════════════════════╝

export DISPLAY=":0"
#export XAUTHORITY="/home/${USER_NAME}/.Xauthority" # for sddm
export XAUTHORITY="/run/user/1000/lyxauth" # for ly

USER_NAME=$(id -un)
USER_ID=$(id -u)

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${USER_ID}/bus"

pgrep bspwm > /dev/null || exit 0

# Get the output of xrandr
XRANDR_OUTPUT=$(xrandr)

# Extract connected monitors and their resolutions
CONNECTED_MONITORS=$(echo "$XRANDR_OUTPUT" | grep " connected" | awk '{print $1}')

# Default desktop names
DEFAULT_DESKTOPS=("TERM" "MERG" "CODE" "WEBM" "EDIT" "MPTY" "CHAT" "LATX" "MUSI" "MISC")

# Calculate total number of connected monitors
NUM_MONITORS=$(echo "$CONNECTED_MONITORS" | wc -l)

# Calculate number of desktops per monitor
if [ $NUM_MONITORS -gt 1 ]; then
    MAIN_MONITOR_DESKTOPS=5
    OTHER_MONITOR_DESKTOPS=5
else
    MAIN_MONITOR_DESKTOPS=10
    OTHER_MONITOR_DESKTOPS=0
fi

# Function to get the maximum resolution of a monitor
get_max_resolution() {
    MONITOR_NAME=$1
    RESOLUTIONS=$(echo "$XRANDR_OUTPUT" | awk -v monitor="$MONITOR_NAME" 'flag && $1 ~ /^[0-9]/ {print $1} $1 == monitor {flag=1} $1 != monitor && flag {flag=0}')
    MAX_RESOLUTION=$(echo "$RESOLUTIONS" | sort -r | head -n 1)
    echo "$MAX_RESOLUTION"
}

# Function to set the monitor to its maximum resolution with offset
set_monitor_resolution_with_offset() {
    MONITOR_NAME=$1
    MAX_RESOLUTION=$(get_max_resolution $MONITOR_NAME)
    OFFSET=$2
    xrandr --output $MONITOR_NAME --mode $MAX_RESOLUTION --pos ${OFFSET}x0
}

# Print the connected monitors and set their maximum resolutions with offsets
echo "Connected monitors and their maximum resolutions:"
OFFSET=0
for MONITOR in $CONNECTED_MONITORS; do
    MAX_RESOLUTION=$(get_max_resolution $MONITOR)
    echo "$MONITOR: $MAX_RESOLUTION"
    set_monitor_resolution_with_offset $MONITOR $OFFSET

    # Determine desktops for this monitor
    if [ $MONITOR = $(echo "$CONNECTED_MONITORS" | head -n 1) ]; then
        DESKTOPS=("${DEFAULT_DESKTOPS[@]:0:$MAIN_MONITOR_DESKTOPS}")
    else
        DESKTOPS=("${DEFAULT_DESKTOPS[@]:$MAIN_MONITOR_DESKTOPS:$OTHER_MONITOR_DESKTOPS}")
    fi

    # Add the monitor to BSPWM with desktops
    bspc monitor $MONITOR -d "${DESKTOPS[@]}"

    WIDTH=$(echo $MAX_RESOLUTION | cut -d'x' -f1)
    OFFSET=$((OFFSET + WIDTH))
done

# Remove extra desktops if monitors were disconnected
for MONITOR in $(bspc query -M --names); do
    if ! [[ "$CONNECTED_MONITORS" =~ "$MONITOR" ]]; then
        bspc monitor $MONITOR -r
    fi
done

/home/${USER_NAME}/.config/polybar/scripts/launch.sh &
