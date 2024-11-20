#!/bin/bash
set -euo pipefail
# Constants for color formatting
RESET="\033[0m"
declare -A COLORS=(
	["bright_white"]="\033[97m" ["black"]="\033[30m" ["red"]="\033[31m" 
	["green"]="\033[32m" ["yellow"]="\033[33m" ["blue"]="\033[34m"
	["magenta"]="\033[35m" ["cyan"]="\033[36m" ["white"]="\033[37m"
	["bg_black"]="\033[40m" ["bg_red"]="\033[41m" ["bg_green"]="\033[42m" 
	["bg_yellow"]="\033[43m" ["bg_blue"]="\033[44m" ["bg_magenta"]="\033[45m" 
	["bg_cyan"]="\033[46m" ["bg_white"]="\033[47m" ["bg_bright_black"]="\033[100m" 
	["bg_bright_red"]="\033[101m" ["bg_bright_green"]="\033[102m" 
	["bg_bright_yellow"]="\033[103m" ["bg_bright_blue"]="\033[104m" 
	["bg_bright_magenta"]="\033[105m" ["bg_bright_cyan"]="\033[106m" 
	["bg_bright_white"]="\033[107m" 
)

# Helper functions
color_text() { echo -e "${COLORS[$1]}$2${RESET}"; }

center_text() {
	local text="$1" cols=$(tput cols)
	while IFS= read -r line; do
		local padding=$(( (cols - ${#line}) / 2 ))
		printf "%*s%s\n" "$padding" " " "$line"
	done <<< "$text"
}

# System information functions
display_system_info() {
	local os="$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release | tr -d '"')"
	local hostname="$(hostname)"
	local model="$(awk '!(NR%2){print$1,p}{p=$0}' /sys/devices/virtual/dmi/id/board_{name,vendor})"
	local kernel_name="$(uname -s)"
	local kernel_ver="$(uname -r)"
	local uptime="$(uptime -p)"
	center_text "$(color_text "bg_green" "Operating System: $os")"
	center_text "$(color_text "bg_bright_green" "Host: $hostname")"
	center_text "$(color_text "bg_bright_blue" "Model: $model")"
	center_text "$(color_text "bg_yellow" "Kernel: $kernel_name $kernel_ver")"
	center_text "$(color_text "bg_cyan" "Uptime: $uptime")"
}

display_memory_usage() {
	local mem=$(free -h --si | awk '/^Mem/ {print $3 "/" $2}')
	local mem_pct=$(free --si | awk '/^Mem/ {printf("%.2f%%", $3/$2 * 100)}')
	local swap=$(free -h --si | awk '/^Swap/ {print $3 "/" $2}')
	local swap_pct=$(free --si | awk '/^Swap/ {printf("%.2f%%", $3/$2 * 100)}')
	center_text "$(color_text "bg_bright_cyan" "Memory: $mem ($mem_pct)")"
	center_text "$(color_text "bg_bright_yellow" "Swap: $swap ($swap_pct)")"
}

display_cpu_info() {
	local cpu_model=$(awk -F: '/^model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^[ \t]*//')
	local cpu_cores=$(grep -c ^processor /proc/cpuinfo)
	center_text "$(color_text "bg_bright_magenta" "CPU Model: $cpu_model")"
	center_text "$(color_text "bg_blue" "CPU Cores: $cpu_cores")"
}

display_temperature_info() {
	local cpu_temp=$(sensors | awk '/^Package id 0:/ {print $4}')
	[ -n "$cpu_temp" ] && center_text "$(color_text "bg_red" "CPU Temperature: $cpu_temp")"
}

display_disk_usage() {
	center_text "$(color_text "bg_yellow" "Disk I/O Statistics")"
	iostat | while IFS= read -r line; do center_text "$line"; done
	
	center_text "$(color_text "bg_bright_black" "Mounted Drives")"
	local drives=$(df -h | awk 'NR==1 {next} {printf "%-20s %6s %6s %6s\n", $1, $2, $3, $5}')
	while IFS= read -r line; do center_text "$line"; done <<< "$drives"
}

display_battery_info() {
	local battery_info=$(upower -i $(upower -e | grep BAT) | grep -E "state|to full|percentage")
	center_text "$(color_text "bg_bright_black" "Battery Info")"
	while IFS= read -r line; do center_text "$line"; done <<< "$battery_info"
}

display_network_info() {
	local ip_address=$(hostname -i | awk '{print $1}')
	local gateway=$(ip route | awk '/default/ {print $3}')
	local dns=$(awk '/nameserver/ {print $2}' /etc/resolv.conf | tr '\n' ' ')
	center_text "$(color_text "bg_cyan" "IP Address: $ip_address")"
	center_text "$(color_text "bg_cyan" "Gateway: $gateway")"
	center_text "$(color_text "bg_cyan" "DNS: $dns")"
}

display_gpu(){
local gpu_info=$(lspci | grep VGA | cut -d ':' -f 3 | cut -d '[' -f 1,2 | sed 's/^ *//')
center_text "$(color_text "bg_yellow" "GPU INFO: $gpu_info")"
}
# Main function to display all information
display_info() {
display_system_info
display_memory_usage
display_cpu_info
display_temperature_info
display_gpu
display_disk_usage
display_battery_info
display_network_info

}

# Entry point
display_info
