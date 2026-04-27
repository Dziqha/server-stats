#!/bin/bash

# Server Performance Stats Analysis Script
# This script analyzes basic server performance statistics

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

print_subheader() {
    echo -e "\n${BLUE}--- $1 ---${NC}"
}

# Main header
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   SERVER PERFORMANCE STATS ANALYZER   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo -e "${YELLOW}Analysis Date: $(date '+%Y-%m-%d %H:%M:%S')${NC}"


print_header "SYSTEM INFORMATION"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${GREEN}OS:${NC} $PRETTY_NAME"
else
    echo -e "${GREEN}OS:${NC} $(uname -s) $(uname -r)"
fi

echo -e "${GREEN}Kernel:${NC} $(uname -r)"

echo -e "${GREEN}Hostname:${NC} $(hostname)"

uptime_info=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
echo -e "${GREEN}Uptime:${NC} $uptime_info"

load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo -e "${GREEN}Load Average:${NC} $load_avg"


print_header "CPU USAGE"

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'%' -f1)

if [ -z "$cpu_usage" ]; then
    if command -v mpstat &> /dev/null; then
        cpu_usage=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF}')
    else
        cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.2f", usage}')
    fi
fi

echo -e "${GREEN}Total CPU Usage:${NC} ${YELLOW}${cpu_usage}%${NC}"

cpu_cores=$(nproc)
echo -e "${GREEN}CPU Cores:${NC} $cpu_cores"


print_header "MEMORY USAGE"

memory_stats=$(free -h | grep "Mem:")
total_mem=$(echo $memory_stats | awk '{print $2}')
used_mem=$(echo $memory_stats | awk '{print $3}')
free_mem=$(echo $memory_stats | awk '{print $4}')
available_mem=$(echo $memory_stats | awk '{print $7}')

mem_total_kb=$(free | grep "Mem:" | awk '{print $2}')
mem_used_kb=$(free | grep "Mem:" | awk '{print $3}')
mem_percentage=$(awk "BEGIN {printf \"%.2f\", ($mem_used_kb/$mem_total_kb)*100}")

echo -e "${GREEN}Total Memory:${NC} $total_mem"
echo -e "${GREEN}Used Memory:${NC} ${YELLOW}$used_mem ($mem_percentage%)${NC}"
echo -e "${GREEN}Free Memory:${NC} ${GREEN}$free_mem${NC}"
echo -e "${GREEN}Available Memory:${NC} $available_mem"

swap_stats=$(free -h | grep "Swap:")
if [ ! -z "$swap_stats" ]; then
    swap_total=$(echo $swap_stats | awk '{print $2}')
    swap_used=$(echo $swap_stats | awk '{print $3}')
    swap_free=$(echo $swap_stats | awk '{print $4}')
    
    if [ "$swap_total" != "0B" ]; then
        swap_total_kb=$(free | grep "Swap:" | awk '{print $2}')
        swap_used_kb=$(free | grep "Swap:" | awk '{print $3}')
        if [ "$swap_total_kb" -gt 0 ]; then
            swap_percentage=$(awk "BEGIN {printf \"%.2f\", ($swap_used_kb/$swap_total_kb)*100}")
            echo -e "\n${GREEN}Swap Total:${NC} $swap_total"
            echo -e "${GREEN}Swap Used:${NC} ${YELLOW}$swap_used ($swap_percentage%)${NC}"
            echo -e "${GREEN}Swap Free:${NC} ${GREEN}$swap_free${NC}"
        fi
    fi
fi


print_header "DISK USAGE"

echo -e "${GREEN}Filesystem Usage:${NC}\n"
df -h | grep -E '^/dev/' | while read line; do
    filesystem=$(echo $line | awk '{print $1}')
    size=$(echo $line | awk '{print $2}')
    used=$(echo $line | awk '{print $3}')
    available=$(echo $line | awk '{print $4}')
    use_percent=$(echo $line | awk '{print $5}')
    mount_point=$(echo $line | awk '{print $6}')
    
    if [ "${use_percent%\%}" -ge 90 ]; then
        color=$RED
    elif [ "${use_percent%\%}" -ge 70 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi
    
    echo -e "${BLUE}Mount Point:${NC} $mount_point"
    echo -e "  ${GREEN}Filesystem:${NC} $filesystem"
    echo -e "  ${GREEN}Total Size:${NC} $size"
    echo -e "  ${GREEN}Used:${NC} ${color}$used ($use_percent)${NC}"
    echo -e "  ${GREEN}Available:${NC} $available"
    echo ""
done

print_header "TOP 5 PROCESSES BY CPU USAGE"

echo -e "${GREEN}%-10s %-10s %-10s %-s${NC}" "PID" "USER" "CPU%" "COMMAND"
echo "------------------------------------------------------------"
ps aux --sort=-%cpu | head -n 6 | tail -n 5 | while read line; do
    pid=$(echo $line | awk '{print $2}')
    user=$(echo $line | awk '{print $1}')
    cpu=$(echo $line | awk '{print $3}')
    command=$(echo $line | awk '{print $11}')
    
    printf "%-10s %-10s ${YELLOW}%-10s${NC} %-s\n" "$pid" "$user" "$cpu%" "$command"
done

print_header "TOP 5 PROCESSES BY MEMORY USAGE"

echo -e "${GREEN}%-10s %-10s %-10s %-s${NC}" "PID" "USER" "MEM%" "COMMAND"
echo "------------------------------------------------------------"
ps aux --sort=-%mem | head -n 6 | tail -n 5 | while read line; do
    pid=$(echo $line | awk '{print $2}')
    user=$(echo $line | awk '{print $1}')
    mem=$(echo $line | awk '{print $4}')
    command=$(echo $line | awk '{print $11}')
    
    printf "%-10s %-10s ${YELLOW}%-10s${NC} %-s\n" "$pid" "$user" "$mem%" "$command"
done

print_header "USER INFORMATION"

logged_users=$(who | wc -l)
echo -e "${GREEN}Currently Logged In Users:${NC} $logged_users"

if [ $logged_users -gt 0 ]; then
    echo -e "\n${GREEN}Active Sessions:${NC}"
    who | awk '{printf "  - %s from %s (logged in at %s %s)\n", $1, $5, $3, $4}'
fi

if [ -f /var/log/auth.log ]; then
    failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
    if [ ! -z "$failed_logins" ]; then
        echo -e "\n${GREEN}Failed Login Attempts (auth.log):${NC} ${RED}$failed_logins${NC}"
    fi
elif [ -f /var/log/secure ]; then
    failed_logins=$(grep "Failed password" /var/log/secure 2>/dev/null | wc -l)
    if [ ! -z "$failed_logins" ]; then
        echo -e "\n${GREEN}Failed Login Attempts (secure):${NC} ${RED}$failed_logins${NC}"
    fi
fi

print_header "SUMMARY"

echo -e "${GREEN}✓${NC} System analysis completed successfully"
echo -e "${GREEN}✓${NC} All metrics collected and displayed"
echo -e "\n${YELLOW}Note:${NC} Some metrics may require root privileges for full access"

echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Analysis Complete!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
