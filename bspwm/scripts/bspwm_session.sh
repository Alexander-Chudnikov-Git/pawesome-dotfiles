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

session_dir="$HOME/.config/bspwm/presistent_values/session"
session_file="$session_dir/${USER}_session"

save_session() {
  mkdir -p "$session_dir"
  > "$session_file"

  wmctrl -l -G | while read -r id desktop x y w h machine_name title; do
    if [[ "$desktop" == "-1" ]]; then
      continue
    fi

    class=$(xprop -id "$id" WM_CLASS | awk -F '"' '{print $2}')

    if ! pgrep -x "$class"; then
      class=$(xprop -id "$id" WM_CLASS | awk -F '"' '{print $4}')
    fi

    if ! pgrep -x "$class"; then
      class=$(xprop -id "$id" WM_CLASS | awk -F '"' '{print $2}')
    fi

    name=$(xprop -id "$id" WM_NAME | awk -F '"' '{print $2}')

    if [[ -n "$class" ]]; then
        echo "restore-by-class:$class:$x:$y:$w:$h" >> "$session_file"
    elif [[ -n "$name" ]]; then
        echo "restore-by-name:$name:$x:$y:$w:$h" >> "$session_file"
    fi
  done
}

restore_session() {
  if [ -f "$session_file" ]; then
    while read -r line; do
      IFS=':' read -r type value x y w h <<< "$line"

      if [[ "$type" == "restore-by-class" ]]; then
        if ! pgrep -x "$value"; then
          "$value" &
          sleep 0.5
        fi

        win_id=$(wmctrl -l -G | awk -v c="$value" '$7 ~ c {print $1; exit}')

        if [[ -n "$win_id" ]]; then
          wmctrl -i -r "$win_id" -e "0,$x,$y,$w,$h"
        fi
      elif [[ "$type" == "restore-by-name" ]]; then
        "$name" &
        sleep 0.5

        win_id=$(wmctrl -l -G | awk -v n="$name" '$0 ~ n {print $1; exit}')

        if [[ -n "$win_id" ]]; then
          wmctrl -i -r "$win_id" -e "0,$x,$y,$w,$h"
        fi
      fi
    done < "$session_file"
    rm "$session_file"
  fi
}

while getopts "rs" opt; do
  case $opt in
    r)
      restore_session
      ;;
    s)
      save_session
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ $OPTIND -eq 1 ]; then
  echo "Usage: $0 [-r|-s]"
  echo "  -r: Restore session"
  echo "  -s: Save session"
fi
