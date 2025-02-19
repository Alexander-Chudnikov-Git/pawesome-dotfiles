#!/bin/bash

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

LOCK_FILE="/tmp/polybar_launcher.lock"

source ~/.config/bspwm/scripts/common.sh

main() {
    if acquire_lock; then
        log_message "Initializing polybar"

        export DISPLAY=":0"
        #export XAUTHORITY="/home/${USER_NAME}/.Xauthority" # for sddm
        export XAUTHORITY="/run/user/1000/lyxauth" # for ly

        USER_NAME=$(id -un)
        USER_ID=$(id -u)

        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${USER_ID}/bus"

        # Kill existing polybar instances
        killall -q polybar

        # Wait for polybar to stop (up to 5 seconds)
        for i in $(seq 1 10); do
            if ! pgrep -u "$USER_ID" -x polybar >/dev/null; then
                break
            fi
            sleep 0.5
        done

        # Iterate through monitors and launch polybar instances
        polybar --list-monitors | cut -d":" -f1 | while read -r monitor; do
            log_message "├ Creating instance for monitor: $monitor"
            if xrandr -q | grep -wq "$monitor connected primary"; then
                run_detached "$monitor" "polybar top -c \"/home/${USER_NAME}/.config/polybar/config.ini\""
            else
                run_detached "$monitor" "polybar top-no-tray -c \"/home/${USER_NAME}/.config/polybar/config.ini\""
            fi

            run_detached "$monitor" "polybar main -c \"/home/${USER_NAME}/.config/polybar/config.ini\""
        done

        release_lock
    else
        exit 1
    fi
}

main "$@"
