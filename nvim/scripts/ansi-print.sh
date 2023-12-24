#!/bin/bash

print_ascii() {
    if [[ -f "$image_source" && ! "$image_source" =~ (png|jpg|jpeg|jpe|svg|gif) ]]; then
        ascii_data="$(< "$image_source")"
    elif [[ "$image_source" == "ascii" || $image_source == auto ]]; then
        :
    else
        ascii_data="$image_source"
    fi

    # Set locale to get correct padding.
    LC_ALL="$sys_locale"

    # Calculate size of ascii file in line length / line count.
    while IFS=$'\n' read -r line; do
        line=${line//\\\\/\\}
        line=$(echo -e "$line" | sed -E 's/█//g; s/\x1B\[[0-9;]*[a-zA-Z]//g')
        ((++lines,${#line}>ascii_len)) && ascii_len="${#line}"
    done <<< "${ascii_data//\$\{??\}}"

    ((text_padding=ascii_len))

    while IFS= read -r line; do
        printf '%*b%b\n' $text_padding "\e[2K\e[${ascii_len}D" "$line"
    done <<< "$ascii_data${reset}"

    # Calculate left padding to center the image
    # ((left_padding=(COLUMNS - text_padding) / 2))
    
    # Print each line with left padding
    # while IFS= read -r line; do
    #     printf '%*b%b\n' $left_padding "" "$line"
    # done <<< "$ascii_data${reset}"

    LC_ALL=C
}

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <ascii_image_filename>"
    exit 1
fi

# Assign the argument to image_source
image_source=$1

# Call the print_ascii function
print_ascii