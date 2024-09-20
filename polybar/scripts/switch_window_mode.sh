#!/bin/bash

FILE_PATH="/home/chooisfox/.config/bspwm/presistent_values/monitor_mode"
VALID_MODES=("0" "1")

LOCKFILE="/tmp/mode-change.lock"

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

get_current_value() {
    if [[ -f "$FILE_PATH" ]]; then
        cat "$FILE_PATH"
    else
        echo ""
    fi
}

set_value() {
    local new_value="$1"
    echo "$new_value" > "$FILE_PATH"
}

switch_to_next_mode() {
    local current_value
    current_value=$(get_current_value)
    local index
    index=$(printf "%s\n" "${VALID_MODES[@]}" | grep -nx "^$current_value$" | cut -d: -f1)

    if [[ -z "$index" ]]; then
        new_value="${VALID_MODES[0]}"
    else
        local next_index=$(((index % ${#VALID_MODES[@]})))
        new_value="${VALID_MODES[next_index % ${#VALID_MODES[@]}]}"
    fi

    set_value "$new_value"
    echo "Switched to mode: $new_value"
}

main() {
    local mode_arg=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --mode | -m)
                mode_arg="$2"
                shift 2
                ;;
            *)
                echo "Usage: $0 [--mode|-m <mode>]"
                exit 1
                ;;
        esac
    done

    if [[ -n "$mode_arg" ]]; then
        if [[ " ${VALID_MODES[*]} " == *" $mode_arg "* ]]; then
            set_value "$mode_arg"
            notify-send "Monitor mode switched to: $mode_arg"
        else
            echo "Invalid mode: $mode_arg. Setting to the first valid mode."
            set_value "${VALID_MODES[0]}"
        fi
    else
        switch_to_next_mode
    fi

    ~/.config/bspwm/scripts/monitor_setup.sh &
}

lock_file
main "$@"
unlock_file
