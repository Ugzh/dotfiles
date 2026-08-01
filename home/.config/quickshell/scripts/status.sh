#!/usr/bin/env bash
set -u

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total_a=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_a=$((idle + iowait))
sleep 0.12
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total_b=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_b=$((idle + iowait))
total_delta=$((total_b - total_a))
idle_delta=$((idle_b - idle_a))
cpu=0
if (( total_delta > 0 )); then
    cpu=$((100 * (total_delta - idle_delta) / total_delta))
fi

mem_total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_available_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
mem_used_kb=$((mem_total_kb - mem_available_kb))
mem_percent=$((100 * mem_used_kb / mem_total_kb))
mem_used_gb=$(awk -v value="$mem_used_kb" 'BEGIN {printf "%.1f", value / 1048576}')

battery_present=false
battery_capacity=0
battery_status=""
battery_path=$(find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT*' -print -quit 2>/dev/null || true)
if [[ -n "$battery_path" ]]; then
    battery_present=true
    battery_capacity=$(<"$battery_path/capacity")
    battery_status=$(<"$battery_path/status")
fi

backlight_present=false
backlight_percent=0
backlight_path=$(find /sys/class/backlight -mindepth 1 -maxdepth 1 -type l -print -quit 2>/dev/null || true)
if [[ -n "$backlight_path" ]]; then
    backlight_present=true
    brightness=$(<"$backlight_path/brightness")
    max_brightness=$(<"$backlight_path/max_brightness")
    if (( max_brightness > 0 )); then
        backlight_percent=$((100 * brightness / max_brightness))
    fi
fi

vpn_text=""
vpn_class="inactive"
vpn_tooltip="WireGuard désactivé"
active_connections=$(nmcli -t -f NAME connection show --active 2>/dev/null || true)
if grep -Fxq "ugo-public" <<<"$active_connections"; then
    vpn_text=" P"
    vpn_class="active-public"
    vpn_tooltip="WireGuard : ugo-public"
elif grep -Fxq "ugo-gpu" <<<"$active_connections"; then
    vpn_text=" G"
    vpn_class="active-gpu"
    vpn_tooltip="WireGuard : ugo-gpu"
fi

network_text="󰤮"
network_tooltip="Réseau déconnecté"
wifi_line=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "yes" {print $2 ":" $3; exit}')
if [[ -n "$wifi_line" ]]; then
    wifi_ssid=${wifi_line%:*}
    wifi_signal=${wifi_line##*:}
    if (( wifi_signal >= 75 )); then
        network_text="󰤨"
    elif (( wifi_signal >= 50 )); then
        network_text="󰤥"
    elif (( wifi_signal >= 25 )); then
        network_text="󰤢"
    else
        network_text="󰤟"
    fi
    network_tooltip="$wifi_ssid (${wifi_signal}%)"
elif nmcli -t -f TYPE,STATE device status 2>/dev/null | grep -q '^ethernet:connected$'; then
    network_text="󰈀"
    network_tooltip="Ethernet connecté"
fi

jq -cn \
    --argjson cpu "$cpu" \
    --arg memoryUsed "$mem_used_gb" \
    --argjson memoryPercent "$mem_percent" \
    --argjson batteryPresent "$battery_present" \
    --argjson batteryCapacity "$battery_capacity" \
    --arg batteryStatus "$battery_status" \
    --argjson backlightPresent "$backlight_present" \
    --argjson backlightPercent "$backlight_percent" \
    --arg vpnText "$vpn_text" \
    --arg vpnClass "$vpn_class" \
    --arg vpnTooltip "$vpn_tooltip" \
    --arg networkText "$network_text" \
    --arg networkTooltip "$network_tooltip" \
    '{
        cpu: $cpu,
        memoryUsed: $memoryUsed,
        memoryPercent: $memoryPercent,
        batteryPresent: $batteryPresent,
        batteryCapacity: $batteryCapacity,
        batteryStatus: $batteryStatus,
        backlightPresent: $backlightPresent,
        backlightPercent: $backlightPercent,
        vpnText: $vpnText,
        vpnClass: $vpnClass,
        vpnTooltip: $vpnTooltip,
        networkText: $networkText,
        networkTooltip: $networkTooltip
    }'
