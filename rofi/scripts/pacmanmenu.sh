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

# Function to prompt for password
prompt_for_password() {
    password=$(zenity --password --title="Password Prompt")
    echo "$password"
}

# Function to perform actions as sudo
perform_sudo_action() {
    action="$1"
    package="$2"
    password=$(prompt_for_password)
    output=$(echo "$password" | echo "Y" | sudo -S $action "$package" 2>&1)
    filtered_output=$(echo "$output" | awk '/checking dependencies/{found=1} found')
    zenity --info --text="$output" --width=600 --height=400 --title="Command Output"

}

# Get list of installed packages and their sizes
packages=$(pacman -Qi | awk '/^Name/{name=$3}/^Installed Size/{size=$4; unit=$5}/^$/ && name {print name,size,unit; name=""}')

# Convert sizes to bytes and sort packages by size (in descending order)
sorted_packages=$(echo "$packages" | awk '{size_bytes=0; if ($3 == "B") size_bytes=$2; else if ($3 == "KiB") size_bytes=$2*1024; else if ($3 == "MiB") size_bytes=$2*1024*1024; else if ($3 == "GiB") size_bytes=$2*1024*1024*1024; print $1, size_bytes}' | sort -k2 -nr)

# Format options for rofi (package name followed by size and unit)
options=$(echo "$sorted_packages" | awk '{size=$2; unit="B"; if (size >= 1024*1024*1024) {size=size/(1024*1024*1024); unit="GiB";} else if (size >= 1024*1024) {size=size/(1024*1024); unit="MiB";} else if (size >= 1024) {size=size/1024; unit="KiB";} print $1 " (" size " " unit ")"}' | rofi -dmenu -p "Select a package:" -theme ~/.config/rofi/themes/appsmenu.rasi)

# Extract package name from selected option
selected_package=$(echo "$options" | awk '{print $1}')

# If a package is selected, prompt the user with additional options
if [ -n "$selected_package" ]; then
    # Display options to the user
    action=$(echo -e "Update\nDelete\nGit" | rofi -dmenu -p "Select an action:" -theme ~/.config/rofi/themes/appsmenu.rasi)

    # Perform actions based on user choice
    case "$action" in
        "Update")
            perform_sudo_action "pacman -Syu" "$selected_package" ;;
        "Delete")
            perform_sudo_action "pacman -Rns" "$selected_package" ;;
        "Git")
            # Extract the Git URL from the package information
            git_url=$(pacman -Qi "$selected_package" | awk '/^URL/{print $3}')
            # Open the Git URL in a web browser
            xdg-open "$git_url" ;;
        *)
            echo "No action selected" ;;
    esac
fi

