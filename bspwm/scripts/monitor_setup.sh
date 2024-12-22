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

LOCKFILE="/tmp/hotplug-screen.lock"

lock_file() {
    if [ -e "${LOCKFILE}" ] && kill -0 $(cat "${LOCKFILE}"); then
        echo "Already running"
        exit
    fi

    trap "unlock_file" INT TERM EXIT
    echo $$ > "${LOCKFILE}"
}

unlock_file() {
    sleep 1
    rm -f "${LOCKFILE}"
}

usage() {
    echo "usage: monitor_setup [monitor option]"
    echo
    echo "Options:"
    echo "   -m, --mirror         - mirror main display to other"
    echo "   -e, --extend         - extend main display"
    echo "   -h, --help           - display help prompt"
    exit
}

manage_monitor_mode() {
    local FILE_PATH="/home/${USER_NAME}/.config/bspwm/presistent_values/monitor_mode"

    if [ ! -f "$FILE_PATH" ]; then
        mkdir -p "$(dirname "$FILE_PATH")"
        echo 0 > "$FILE_PATH"
        export WINDOW_MODE=0
    else
        local value
        value=$(cat "$FILE_PATH")

        if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
            echo 0 > "$FILE_PATH"
            export WINDOW_MODE=0
        else
            export WINDOW_MODE="$value"
        fi
    fi
}

restart_process() {
    local process=$1
    local command=${2:-$1}
    killall "$process" &>/dev/null
    "$command" &
}

get_max_resolution() {
    MONITOR_NAME=$1
    RESOLUTIONS=$(echo "$XRANDR_OUTPUT" | awk -v monitor="$MONITOR_NAME" '
        flag && $1 ~ /^[0-9]/ {print $1}
        $1 == monitor {flag=1}
        $1 != monitor && flag {flag=0}')
    echo "$RESOLUTIONS" | sort -r | head -n 1
}

calculate_scale() {
    MONITOR_RESOLUTION=$1
    MAIN_RESOLUTION=$2
    MONITOR_WIDTH=$(echo "$MONITOR_RESOLUTION" | cut -d'x' -f1)
    MONITOR_HEIGHT=$(echo "$MONITOR_RESOLUTION" | cut -d'x' -f2)
    MAIN_WIDTH=$(echo "$MAIN_RESOLUTION" | cut -d'x' -f1)
    MAIN_HEIGHT=$(echo "$MAIN_RESOLUTION" | cut -d'x' -f2)

    SCALE_X=$(echo "scale=4; $MAIN_WIDTH / $MONITOR_WIDTH" | bc)
    SCALE_Y=$(echo "scale=4; $MAIN_HEIGHT / $MONITOR_HEIGHT" | bc)
    echo "${SCALE_X}x${SCALE_Y}"
}

set_monitor_resolution_with_offset() {
    MONITOR_NAME=$1
    MAX_RESOLUTION=$(get_max_resolution "$MONITOR_NAME")
    OFFSET=$2
    xrandr --output "$MONITOR_NAME" --mode "$MAX_RESOLUTION" --pos ${OFFSET}x0 --scale 1x1
}

set_monitor_mirror() {
    MONITOR_NAME=$1
    MAIN_MONITOR_NAME=$2
    MAIN_RESOLUTION=$3
    MONITOR_RESOLUTION=$(get_max_resolution "$MONITOR_NAME")
    SCALE=$(calculate_scale "$MONITOR_RESOLUTION" "$MAIN_RESOLUTION")
    xrandr --output "$MONITOR_NAME" --mode "$MONITOR_RESOLUTION" --scale "$SCALE" --same-as "$MAIN_MONITOR_NAME"
}

remove_unconnected_monitors() {
    CONNECTED_MONITORS=$1
    for MONITOR in $(bspc query -M --names); do
        if ! echo "$CONNECTED_MONITORS" | grep -q "$MONITOR"; then
            bspc monitor "$MONITOR" -r
        fi
    done
}

main() {
    killall -q "polybar"

    export DISPLAY=":0"
    export XAUTHORITY="/run/user/1000/lyxauth"

    USER_NAME=$(id -un)
    USER_ID=$(id -u)

    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${USER_ID}/bus"

    pgrep bspwm > /dev/null || exit 0

    XRANDR_OUTPUT=$(xrandr)
    CONNECTED_MONITORS=$(echo "$XRANDR_OUTPUT" | grep " connected" | awk '{print $1}')
    NUM_MONITORS=$(echo "$CONNECTED_MONITORS" | wc -l)
    DEFAULT_DESKTOPS=("TERM" "MERG" "CODE" "WEBM" "EDIT" "MPTY" "CHAT" "LATX" "MUSI" "MISC")

    if [ $# -eq 0 ]; then
        manage_monitor_mode
    else
        for i in "$@"; do
            case $i in
                '-m'|'--mirror') WINDOW_MODE=0 ;;
                '-e'|'--extend') WINDOW_MODE=1 ;;
                '-h'|'--help'|'') usage ;;
                *) ;;
            esac
        done
    fi

    if [ $WINDOW_MODE -eq 0 ]; then
        MAIN_MONITOR_NAME=$(xrandr | grep -o "^.*primary" | awk '{print $1}')
        MAIN_RESOLUTION=$(get_max_resolution "$MAIN_MONITOR_NAME")

        xrandr --output "$MAIN_MONITOR_NAME" --mode "$MAIN_RESOLUTION" --pos 0x0 --scale 1x1 # Stupid xorg bug

        for MONITOR in $CONNECTED_MONITORS; do
            if [ "$MONITOR" != "$MAIN_MONITOR_NAME" ]; then
                set_monitor_mirror "$MONITOR" "$MAIN_MONITOR_NAME" "$MAIN_RESOLUTION"
            fi
        done
        bspc monitor "$MAIN_MONITOR_NAME" -d "${DEFAULT_DESKTOPS[@]}"
    else
        MAIN_MONITOR_DESKTOPS=$([ $NUM_MONITORS -gt 1 ] && echo 5 || echo 10)
        OTHER_MONITOR_DESKTOPS=$([ $NUM_MONITORS -gt 1 ] && echo 5 || echo 0)

        OFFSET=0
        for MONITOR in $CONNECTED_MONITORS; do
            MAX_RESOLUTION=$(get_max_resolution "$MONITOR")
            set_monitor_resolution_with_offset "$MONITOR" $OFFSET

            if [ "$MONITOR" = "$(echo "$CONNECTED_MONITORS" | head -n 1)" ]; then
                DESKTOPS=("${DEFAULT_DESKTOPS[@]:0:$MAIN_MONITOR_DESKTOPS}")
            else
                DESKTOPS=("${DEFAULT_DESKTOPS[@]:$MAIN_MONITOR_DESKTOPS:$OTHER_MONITOR_DESKTOPS}")
            fi
            bspc monitor "$MONITOR" -d "${DESKTOPS[@]}"

            WIDTH=$(echo "$MAX_RESOLUTION" | cut -d'x' -f1)
            OFFSET=$((OFFSET + WIDTH))
        done
    fi

    remove_unconnected_monitors "$CONNECTED_MONITORS"

    

    restart_process "lwp" "/home/${USER_NAME}/.config/polybar/scripts/launch.sh"
    restart_process "lwpwlp" "/usr/local/bin/lwpwlp"
}

lock_file
main "$@"
unlock_file
