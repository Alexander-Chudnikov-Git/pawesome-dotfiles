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
    declare -n LOCAL_SMS_ORDER=$3
    local LAST_ID_FILE=".last_sms_id"
    local LAST_ID=0

    # Check for the last processed ID
    [ -f "$LAST_ID_FILE" ] && LAST_ID=$(<"$LAST_ID_FILE")

    while read -r LINE; do
        ID=$(echo "$LINE" | awk '{print $1}')
        STATUS=$(echo "$LINE" | awk '{print $2}')
        if (( ID > LAST_ID )); then
            LOCAL_SMS_LIST[$ID]="$STATUS"
            LOCAL_SMS_ORDER+=("$ID")
        fi
    done < <(mmcli -m "$MODEM_NUMBER" --messaging-list-sms | awk -F'/SMS/' '{print $2}' | awk '{print $1, $2}')

    # Update the last processed ID
    if [[ ${#LOCAL_SMS_ORDER[@]} -gt 0 ]]; then
        echo "${LOCAL_SMS_ORDER[-1]}" > "$LAST_ID_FILE"
    fi
}

print_sms_statuses() {
    declare -n LOCAL_SMS_LIST=$1
    declare -n LOCAL_SMS_ORDER=$2
    for ID in "${LOCAL_SMS_ORDER[@]}"; do
        echo "Message ID: $ID, Status: ${LOCAL_SMS_LIST[$ID]}"
    done
}

convert_iso_to_normal_date() {
    local ISO_DATE="$1"
    date -d "$ISO_DATE" +"%Y-%m-%d %H:%M:%S"
}

truncate_text() {
    local TEXT="$1"
    local MAX_WIDTH="$2"
    [ ${#TEXT} -ge "$MAX_WIDTH" ] && echo "${TEXT:0:$MAX_WIDTH} ..." || echo "$TEXT"
}

format_phone_time() {
    local ID="$1"
    local PHONE="$2"
    local TIME="$3"
    local TOTAL_WIDTH=$4
    local SPACES=$(( TOTAL_WIDTH - ${#ID} - ${#PHONE} - ${#TIME} - 2 ))
    [ $SPACES -lt 0 ] && SPACES=0
    printf "%s: %s%*s%s\n" "$ID" "$PHONE" "$SPACES" "" "$TIME"
}

main() {
    local MODEM_NUMBER
    MODEM_NUMBER=$(get_modem_number)

    declare -A SMS_LIST
    declare -a SMS_ID_ORDER
    read_sms_list "$MODEM_NUMBER" SMS_LIST SMS_ID_ORDER

    local MAX_WIDTH=60

    for ID in "${SMS_ID_ORDER[@]}"; do
        CONTENT=$(mmcli -m "$MODEM_NUMBER" -s "$ID" -J)
        TEXT=$(echo "$CONTENT" | grep -oP '"text":"\K[^"\\n]+')
        PHONE=$(echo "$CONTENT" | grep -oP '"number":"\K[^"]+')
        TIME=$(echo "$CONTENT" | grep -oP '"timestamp":"\K[^"]+')
        TIME=$(convert_iso_to_normal_date "$TIME")

        TRUNCATED_TEXT=$(truncate_text "$TEXT" "$MAX_WIDTH")
        PHONE_TIME=$(format_phone_time "$ID" "$PHONE" "$TIME" 64)

        ROFI_DATA+="$PHONE_TIME\n$TRUNCATED_TEXT\0icon\x1f<span color='#DB9900'>$ID</span>\x0f"
    done

    ROFI_SELECTED_MSG=$(echo -ne "${ROFI_DATA[@]}" | rofi -sep '\x0f' -dmenu -i -p "SMS List" -theme ~/.config/rofi/themes/smsmenu.rasi)

    if [ -n "$ROFI_SELECTED_MSG" ]; then
        SELECTED_ID=$(echo "$ROFI_SELECTED_MSG" | sed -n 's/^\([0-9]*\):.*/\1/p')

        if [ -n "$SELECTED_ID" ]; then
            FULL_CONTENT=$(mmcli -m "$MODEM_NUMBER" -s "$SELECTED_ID" -J)
            FULL_TEXT=$(echo "$FULL_CONTENT" | grep -oP '"text":"\K[^"\\n]+')
            PHONE=$(echo "$FULL_CONTENT" | grep -oP '"number":"\K[^"]+')
            TIME=$(echo "$FULL_CONTENT" | grep -oP '"timestamp":"\K[^"]+')
            TIME=$(convert_iso_to_normal_date "$TIME")

            yad --form --title="SMS ID: $SELECTED_ID" \
                --align=center \
                --field="SMS ID: $SELECTED_ID":LBL "" \
                --align=left \
                --field="Phone: ":RO "$PHONE" \
                --field="Timestamp: ":RO "$TIME" \
                --field="Message:":LBL "" \
                --field="$FULL_TEXT":LBL ""

            if [ $? -eq 1 ]; then
                echo "Cancel pressed. Exiting."
                exit 0
            else
                echo "OK pressed. Re-opening Rofi."
                main
            fi
        else
            echo "No message selected."
        fi
    else
        echo "No new messages."
    fi
}

# Run the main function
main


