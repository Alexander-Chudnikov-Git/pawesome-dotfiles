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

# Logging
get_calling_filename() {
    if [[ ${#FUNCNAME[@]} -ge 3 ]]; then
        echo "${BASH_SOURCE[2]}"
    else
        echo "${BASH_SOURCE[0]}"
    fi
}

log_message() {
    local message="$1"
    local calling_file
    calling_file=$(get_calling_filename)

    local filename=$(basename "$calling_file")

    logger -t "$filename" "$message"
    echo "$message"
}

# Guard locks
release_lock() {
    if [ -d "$LOCK_FILE" ]; then
        rmdir "$LOCK_FILE"
        log_message "Lock released."
    else
        log_message "Lock file '$LOCK_FILE' does not exist.  Skipping release."
    fi
}

acquire_lock() {
    if mkdir "$LOCK_FILE"; then
        log_message "Lock acquired."
        trap release_lock INT TERM EXIT
        return 0
    else
        log_message "Another instance is already running. Exiting."
        return 1
    fi
}

# Process manipulation
start_process() {
    local process=$1
    local command=${2:-$1}

    echo "├─ Startig process: $process"

    if [[ ! $(pgrep -f $process) ]]; then
        nohup sh -c "$command" </dev/null >/dev/null 2>&1 &
    fi
}

kill_process() {
    local process=$1

    echo "├─ Killing process: $process"

    if [[ $(pgrep -f $process) ]]; then
        killall -q $process
    fi
}

restart_process() {
    local process=$1
    local command=${2:-$1}

    kill_process "$process"
    start_process "$process" "$command"
}

run_detached() {
    local monitor="$1"
    local command="$2"

    if [ -z "$command" ]; then
        return 1
    fi

    echo "Running on monitor '$monitor': $command"
    MONITOR=$monitor nohup sh -c "$command" </dev/null >/dev/null 2>&1 &
}

# BSPC related stuff
apply_bspc_rules() {
    local state=$1
    local focus=$2
    local follow=$3
    local sticky=$4
    local rectangle=$5
    local center=$6
    local layer=$7

    shift 7
    log_message "├┐"

    local last_app="${@: -1}" # Get the last application in the list

    for app in "$@"; do
        if [[ "$app" == "$last_app" ]]; then
            log_message "│└ $app"
        else
            log_message "│├ $app"
        fi
        bspc rule -a "$app" state="$state" focus="$focus" follow="$follow" sticky="$sticky" rectangle="$rectangle" center="$center" layer="$layer"
    done
}

