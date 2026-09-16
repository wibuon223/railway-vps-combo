#!/bin/bash
# SSH Login Banner
[ -t 1 ] || return 0 2>/dev/null || exit 0

C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'
C_CYAN=$'\e[38;5;51m'; C_BLUE=$'\e[38;5;33m'; C_GREEN=$'\e[38;5;46m'
C_YELLOW=$'\e[38;5;220m'; C_GREY=$'\e[38;5;245m'; C_WHITE=$'\e[38;5;231m'

_os="$( . /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Ubuntu 24.04}" )"
_kernel="$(uname -r 2>/dev/null)"
_host="$(hostname 2>/dev/null)"
_user="$(whoami 2>/dev/null)"
_uptime="$(uptime -p 2>/dev/null | sed 's/^up //')"; : "${_uptime:=just now}"
_cpu="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//; s/  */ /g')"
_cores="$(nproc 2>/dev/null)"; : "${_cpu:=CPU}"
_mem="$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " / " $2}')"
_disk="$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
_api_port="${PORT:-8080}"

printf '\n'
printf '%s\n' "${C_CYAN}${C_BOLD}   ____ ___  _     _    ____    ____  ____  _   _ ${C_RESET}"
printf '%s\n' "${C_CYAN}${C_BOLD}  / ___/ _ \| |   / \  | __ )  / ___|/ ___|| | | |${C_RESET}"
printf '%s\n' "${C_BLUE}${C_BOLD} | |  | | | | |  / _ \ |  _ \  \___ \\___ \| |_| |${C_RESET}"
printf '%s\n' "${C_BLUE}${C_BOLD} | |__| |_| | |_/ ___ \| |_) |  ___) |___) |  _  |${C_RESET}"
printf '%s\n' "${C_WHITE}${C_BOLD}  \____\___/|___/_/   \_\____/  |____/|____/|_| |_|${C_RESET}"
printf '\n'
printf '%s\n' "${C_WHITE}${C_BOLD}             Ubuntu 24.04 LTS · Railway Cloud VPS${C_RESET}"
printf '\n'

line="${C_GREY}  ────────────────────────────────────────────────────────────${C_RESET}"
printf '%s\n' "$line"

row() { printf "  ${C_CYAN}%-12s${C_RESET} ${C_DIM}│${C_RESET} %b\n" "$1" "$2"; }
row "User"       "${C_WHITE}${_user}${C_RESET}${C_GREY} @ ${C_WHITE}${_host}${C_RESET}"
row "OS"         "${C_WHITE}${_os}${C_RESET}"
row "Kernel"     "${C_WHITE}${_kernel}${C_RESET}"
row "Uptime"     "${C_WHITE}${_uptime}${C_RESET}"
row "CPU"        "${C_WHITE}${_cpu} ${C_GREY}(${_cores} cores)${C_RESET}"
row "Memory"     "${C_WHITE}${_mem}${C_RESET}"
row "Disk"       "${C_WHITE}${_disk}${C_RESET}"
row "API/Agent"  "${C_GREEN}Port ${_api_port} (Railway HTTP Ingress)${C_RESET}"

printf '%s\n' "$line"
printf "  ${C_YELLOW}💡 Tip:${C_RESET} When running an API server / AI agent, bind it to port ${C_WHITE}${_api_port}${C_RESET}\n"
printf "          to reach it directly via the Railway public domain!\n"
printf '\n'
