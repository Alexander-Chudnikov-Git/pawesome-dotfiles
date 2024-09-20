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

get_modem_number() {
    mmcli -L | awk -F'/Modem/' '{print $2}' | awk '{print $1}'
}

read_sms_list() {
    local MODEM_NUMBER=$1
    declare -n LOCAL_SMS_LIST=$2
    while read -r LINE; do
        ID=$(echo "$LINE" | awk '{print $1}')
        STATUS=$(echo "$LINE" | awk '{print $2}')
        LOCAL_SMS_LIST["$ID"]="$STATUS"
    done < <(mmcli -m "$MODEM_NUMBER" --messaging-list-sms | awk -F'/SMS/' '{print $2}' | awk '{print $1, $2}')
}

print_sms_statuses() {
    declare -n LOCAL_SMS_LIST=$1
    for ID in "${!LOCAL_SMS_LIST[@]}"; do
        echo "Message ID: $ID, Status: ${LOCAL_SMS_LIST[$ID]}"
    done
}

convert_iso_to_normal_date() {
    local ISO_DATE="$1"
    # Use 'date' command to parse the ISO 8601 date
    local NORMAL_DATE=$(date -d "$ISO_DATE" +"%Y-%m-%d %H:%M:%S")
    echo "$NORMAL_DATE"
}

truncate_text() {
    local TEXT="$1"
    local MAX_WIDTH="$2"
    if [ ${#TEXT} -gt "$MAX_WIDTH" ]; then
        echo "${TEXT:0:$MAX_WIDTH} ..."
    else
        echo "$TEXT"
    fi
}

format_phone_time() {
    local PHONE="$1"
    local TIME="$2"
    local TOTAL_WIDTH=$3

    # Calculate the number of spaces needed
    local TOTAL_LENGTH=$(( ${#PHONE} + ${#TIME} ))
    local SPACES=$(( TOTAL_WIDTH - TOTAL_LENGTH ))

    # If the total length is greater than 54, truncate the result
    if [ $SPACES -lt 0 ]; then
        SPACES=0
    fi

    # Print the result with the required number of spaces in between
    printf "%s%*s%s\n" "$PHONE" "$SPACES" "" "$TIME"
}

main() {
    local MODEM_NUMBER
    MODEM_NUMBER=$(get_modem_number)
    echo "Modem number: $MODEM_NUMBER"

    declare -A SMS_LIST
    read_sms_list "$MODEM_NUMBER" SMS_LIST
    print_sms_statuses SMS_LIST

    local MAX_WIDTH=46  # Adjust this based on your Rofi window width

    for ID in "${!SMS_LIST[@]}"; do
        CONTENT=$(mmcli -m "$MODEM_NUMBER" -s "$ID" -J)
        TEXT=$(echo "$CONTENT" | grep -oP '"text":"\K[^"\\n]+')
        PHONE=$(echo "$CONTENT" | grep -oP '"number":"\K[^"]+')
        TIME=$(echo "$CONTENT" | grep -oP '"timestamp":"\K[^"]+')
        TIME=$(convert_iso_to_normal_date "$TIME")

        TRUNCATED_TEXT=$(truncate_text "$TEXT" "$MAX_WIDTH")
        PHONE_TIME=$(format_phone_time "$PHONE" "$TIME" 50)

        # Collect data in the format for Rofi
        ROFI_DATA+="$PHONE_TIME\n$TRUNCATED_TEXT\0icon\x1f<span color='#DB9900'>$ID</span>\x0f"
    done

    ROFI_SELECTED_MSG=$(echo -ne "${ROFI_DATA[@]}" | rofi -sep '\x0f' -dmenu -i -p "SMS List" -theme ~/.config/rofi/themes/smsmenu.rasi)

    echo $ROFI_SELECTED_MSG
}

# Run the main function
main

