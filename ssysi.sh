#!/bin/bash

# Enable strict error handling
set -u

# Function to apply color formatting
color_text() {
    local color=$1
    local text=$2
    declare -A colors=(
        ["bright_white"]="\033[97m" ["bg_black"]="\033[40m" ["bg_red"]="\033[41m"
        ["bg_green"]="\033[42m" ["bg_yellow"]="\033[43m" ["bg_blue"]="\033[44m"
        ["bg_magenta"]="\033[45m" ["bg_cyan"]="\033[46m" ["bg_white"]="\033[47m"
        ["bg_bright_black"]="\033[100m" ["bg_bright_red"]="\033[101m"
        ["bg_bright_green"]="\033[102m" ["bg_bright_yellow"]="\033[103m"
        ["bg_bright_blue"]="\033[104m" ["bg_bright_magenta"]="\033[105m"
        ["bg_bright_cyan"]="\033[106m" ["bg_bright_white"]="\033[107m"
    )
    if [[ -n "${colors[$color]}" ]]; then
        echo -e "${colors[$color]}${text}\033[0m"
    else
        echo "Color '$color' not recognized."
    fi
}

# Function to center text in the terminal
center_text() {
    local text="$1"
    local cols=$(tput cols)
    while IFS= read -r line; do
        local text_length=${#line}
        if [ "$text_length" -lt "$cols" ]; then
            local padding=$(( (cols - text_length) / 2 ))
            printf "%${padding}s%s\n" " " "$line"
        else
            echo "$line"
        fi
    done <<< "$text"
}

# Calculate percentage for memory and swap
get_percentage() {
    local used=$1
    local total=$2
    awk -v used="$used" -v total="$total" 'BEGIN { printf("%.2f%%", (used / total) * 100) }'
}

# Function to display memory and swap usage
display_memory_usage() {
    local memory_usage=$(free -h --si | awk '/^Mem/ {print $3 " / " $2}')
    local swap_usage=$(free -h --si | awk '/^Swap/ {print $3 " / " $2}')

    local memory_used=$(free --si | awk '/^Mem/ {print $3}')
    local memory_total=$(free --si | awk '/^Mem/ {print $2}')
    local memory_percentage=$(get_percentage "$memory_used" "$memory_total")

    local swap_used=$(free --si | awk '/^Swap/ {print $3}')
    local swap_total=$(free --si | awk '/^Swap/ {print $2}')
    local swap_percentage=$(get_percentage "$swap_used" "$swap_total")

    center_text "$(color_text "bg_bright_magenta" " Memory: $memory_usage ($memory_percentage)")"
    center_text "$(color_text "bg_bright_magenta" "Swap: $swap_usage ($swap_percentage)")"
}

# Function to display system info
display_system_info() {
    local os=$(awk -F= '/^PRETTY_NAME=/{print $2}' /etc/os-release | tr -d '"')
    local hostname=$(cat /proc/sys/kernel/hostname)
    local model=$(cat /sys/devices/virtual/dmi/id/board_{name,vendor} | awk '!(NR%2){print$1,p}{p=$0}')

    center_text "$(color_text "bg_green" " Operating System: $os")"
    center_text "$(color_text "bg_green" " Host: $hostname")"
    center_text "$(color_text "bg_green" " Model: $model")"
}

# Function to display CPU information
display_cpu_info() {
    local cpu_model=$(grep "model name" /proc/cpuinfo | cut -d ' ' -f 3- | uniq)
    local cpu_cores=$(awk '/^cpu cores/ {print $4; exit}' /proc/cpuinfo)
    local cpu_threads=$(awk '/^processor/ {count++} END {print count}' /proc/cpuinfo)

    center_text "$(color_text "bg_blue" " CPU: $cpu_model")"
    center_text "$(color_text "bg_blue" " CPU Cores: $cpu_cores")"
    center_text "$(color_text "bg_blue" " CPU Threads: $cpu_threads")"
}

# Function to display disk usage
display_disk_usage() {
    local disk_usage=$(df -h / | awk 'NR==2 {print "(" $5 " used) " $3 "/" $2 }')
    center_text "$(color_text "bg_bright_black" " Disk Usage: $disk_usage")"
}

# Function to display battery status
display_battery_info() {
    local battery_info=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to full|percentage")
    center_text "$(color_text "bg_bright_black" " Battery:")"
    while IFS= read -r line; do
        center_text "$line"
    done <<< "$battery_info"
}

# Function to display top processes by CPU and Memory usage
display_top_processes() {
    center_text "$(color_text "bg_cyan" " Top Processes by CPU Usage")"
    ps -eo pid,%cpu,%mem,cmd --sort=-%cpu | head -n 11 | while IFS= read -r line; do
        center_text "$line"
    done

    center_text "$(color_text "bg_cyan" " Top Processes by Memory Usage")"
    ps -eo pid,%cpu,%mem,cmd --sort=-%mem | head -n 11 | while IFS= read -r line; do
        center_text "$line"
    done
}

# Function to display a random quote
display_quote() {
    local quotes=(
        "Talk is cheap. Show me the code. - Linus Torvalds"
        "Free software is software that respects your freedom and the social solidarity of your community. - Richard Stallman"
        "Given enough eyeballs, all bugs are shallow. - Eric S. Raymond"
        "The Web as I envisaged it, we have not seen it yet. - Tim Berners-Lee"
        "Knowledge is power. - Sir Francis Bacon"
    )
    local random_index=$((RANDOM % ${#quotes[@]}))
    center_text "$(color_text "bg_cyan" "Random Quote: ${quotes[$random_index]}")"
}

# Main function to display all information
display_info() {
    display_system_info
    display_memory_usage
    display_cpu_info
    display_disk_usage
    display_battery_info
    display_top_processes
    display_quote
}

# Entry point
display_info
