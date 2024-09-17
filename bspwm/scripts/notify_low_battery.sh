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

### VARIABLES

POLL_INTERVAL=10    # Polling interval in seconds
MEDIUM_BAT=33       # Medium battery threshold (less than this is considered low)
LOW_BAT=10          # Low battery threshold (less than this is considered critical)

# Battery device path (adjust if necessary)
BAT_PATH=/sys/class/power_supply/BAT0
BAT_STAT=$BAT_PATH/status

# Detect battery capacity and current charge method (mAh or mWh)
if [[ -f $BAT_PATH/charge_full ]]; then
    BAT_FULL=$BAT_PATH/charge_full
    BAT_NOW=$BAT_PATH/charge_now
elif [[ -f $BAT_PATH/energy_full ]]; then
    BAT_FULL=$BAT_PATH/energy_full
    BAT_NOW=$BAT_PATH/energy_now
else
    echo "Battery not detected or unsupported battery interface."
    exit 1
fi

# Ensure required tools are available
if ! command -v notify-send &> /dev/null || ! command -v zenity &> /dev/null; then
    echo "Required tools (notify-send, zenity) not found."
    exit 1
fi

### FUNCTIONS

# Kill any previous instances of the script to avoid duplicate notifications
kill_running() {
    local mypid=$$
    local script_name=${0##*/}

    # Get the list of running PIDs for this script, excluding the current one
    local pids=($(pgrep -f $script_name))

    for pid in "${pids[@]}"; do
        if [[ $pid -ne $mypid ]]; then
            kill $pid
            sleep 1
        fi
    done
}

### MAIN SCRIPT

# Ensure battery is detected before proceeding
if ls -1qA /sys/class/power_supply/ | grep -q BAT; then
    kill_running

    medium_notified=false  # Track if medium battery notification has been sent
    critical_notified=false  # Track if critical battery notification has been sent

    while true; do
        bf=$(cat $BAT_FULL)
        bn=$(cat $BAT_NOW)
        bs=$(cat $BAT_STAT)

        bat_percent=$(( 100 * bn / bf ))  # Calculate battery percentage
        
        # Handle critical battery notification
        if [[ $bat_percent -lt $LOW_BAT && "$bs" = "Discharging" && $critical_notified = false ]]; then
            notify-send --urgency=critical "$bat_percent% : Critical Battery!"
            zenity --warning --text="Critical battery: $bat_percent%.\nPlease plug in the charger." \
                   --title="Battery Warning" --width=500 --height=2500 --timeout=10
            critical_notified=true  # Mark as notified for critical battery
        fi

        # Handle medium battery notification
        if [[ $bat_percent -lt $MEDIUM_BAT && "$bs" = "Discharging" && $medium_notified = false ]]; then
            notify-send --urgency=normal "$bat_percent% : Low Battery!"
            medium_notified=true  # Mark as notified for medium battery
        fi

        # Reset notifications if charging
        if [[ "$bs" = "Charging" ]]; then
            if [[ $bat_percent -gt $LOW_BAT ]]; then
                critical_notified=false  # Reset if battery charges above LOW_BAT
            fi
            if [[ $bat_percent -gt $MEDIUM_BAT ]]; then
                medium_notified=false  # Reset if battery charges above MEDIUM_BAT
            fi
        fi

        sleep $POLL_INTERVAL  # Wait for the next poll
    done
else
    echo "No battery detected."
    exit 1
fi

