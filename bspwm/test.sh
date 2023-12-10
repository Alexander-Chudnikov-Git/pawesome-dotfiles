#! /bin/sh

setup_desktop() {
    local desktop_number=$1; shift
    local app_name=("$@")
    for i in ${app_name[@]}; do
		echo "bspc rule -a $i desktop='^$desktop_number' follow=on focus=on"; done
}

declare -a terminal=(URxvt test)
setup_desktop 10  "${terminal[@]}"
