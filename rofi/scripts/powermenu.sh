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

# Get the screen dimensions
# screen_width=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f1)
# screen_height=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f2)

# Calculate the center of the screen
# center_x=$((screen_width / 2) - 300)
# center_y=$((screen_height / 2) - 250)

options="Power Off\0icon\x1f<span color='#DB1100'>⏻</span>\nExit BSPWM\0icon\x1f<span color='#DB9900'></span>\nSleep Mode\0icon\x1f<span color='#0088DB'>󰿒</span>\nReboot\0icon\x1f<span color='#00A86B'></span>\nShow Hints\0icon\x1f<span color='#B6ADA5'></span>"
                                                                                                 # On some systems rofi positioning is not working
selected_option=$(echo -en "$options" | rofi -dmenu -theme ~/.config/rofi/themes/powermenu.rasi) # -xoffset $center_x -yoffset $center_y

case $selected_option in
    "Power Off")
        systemctl poweroff
        ;;
    "Exit BSPWM")
        bspc quit
        ;;
    "Sleep Mode")
        bspc quit && systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Show Hints")
        # Replace this with the command to show hints or any other action you want.
        echo "Showing hints..."
        ;;
    *)
        echo "Invalid option selected"
        ;;
esac
