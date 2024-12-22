#!/bin/bash
TMP_WINDOW_ID=$(xdotool selectwindow)
unset WINDOW X Y WIDTH HEIGHT SCREEN
eval $(xdotool getwindowgeometry --shell "${TMP_WINDOW_ID}")
xdotool windowfocus --sync "${TMP_WINDOW_ID}"
sleep 0.05
flameshot gui --region "${WIDTH}x${HEIGHT}+${X}+${Y}"
