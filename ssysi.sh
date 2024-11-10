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
	["bg_bright_cyan"]="\033[106m" ["bg_bright_white"]="\033[107m")
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

# Function to display system info like kernel uptime and all related stuff to the system outside of hardware
display_system_info() {
	local os=$(awk -F= '/^PRETTY_NAME=/{print $2}' /etc/os-release | tr -d '"')
	local hostname=$(cat /proc/sys/kernel/hostname)
	local model=$(cat /sys/devices/virtual/dmi/id/board_{name,vendor} | awk '!(NR%2){print$1,p}{p=$0}')
	local kernel_name=$(uname -s)
	local user=$(w)
	local kernel_ver=$(uname -r)
	local kernel_rel=$(uname -v)
	local uptime=$(uptime -p)
	local screen=$(xrandr | grep -oP '\d+x\d+\s+\d+\.\d+\*')

	center_text "$(color_text "bg_green" " Operating System: $os")"
	center_text "$(color_text "bg_green" " Host: $hostname")"
	center_text "$(color_text "bg_green" " Model: $model")"
	center_text "$(color_text "bg_green" "  Logged-in Users $user")"
	center_text "$(color_text "bg_yellow" "  Kernel Name: $kernel_name")"
	center_text "$(color_text "bg_yellow" "  Kernel Version: $kernel_ver ")"
	center_text "$(color_text "bg_yellow" "  Kernel Release: $kernel_rel")"
	center_text "$(color_text "bg_black" "  Resolution: $screen")"
	center_text "$(color_text "bg_black" "  Uptime : $uptime")"
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

# Function to display disk usage and I/O stats and battery
display_disk_usage() {

# Disk I/O statistics section
center_text "$(color_text "bg_yellow" " Disk I/O Statistics")"
local io_stats=$(iostat)
	while IFS= read -r line; do
	center_text "$line"
	done <<< "$io_stats"  # Loop through io_stats and display each line

# Mounted Drives section
	center_text "$(color_text "bg_bright_black" "  Mounted Drives")"
	local header="$(color_text "bg_blue" "      Filesystem                        Size       Used      Use%")"
	center_text "$header"

# Display drives information
	local drives=$(df -h | awk 'NR>1 {printf "      %-30s %-10s %-10s %-10s\n", $1, $2, $3, $5}')
	while IFS= read -r line; do
	center_text "$line"
	done <<< "$drives"  # Loop through drives and display each line

    
# Disk usage for root (/)
	local disk_usage=$(df -h / | awk 'NR==2 {print "(" $5 " used) " $3 "/" $2}')
	center_text "$(color_text "bg_bright_black" " Disk Usage: $disk_usage")"

#battery
        
local battery_info=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to full|percentage")
	center_text "$(color_text "bg_bright_black" " Battery:")"
	while IFS= read -r line; do
	center_text "$line"
	done <<< "$battery_info"
}

# Main function to display all information
display_info() {
    display_system_info
    display_memory_usage
    display_cpu_info
    display_top_processes
    display_disk_usage
}
# Entry point
display_info
