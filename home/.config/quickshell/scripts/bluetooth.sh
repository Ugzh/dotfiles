#!/usr/bin/env bash
set -u

notify_error() {
    notify-send -u critical "Bluetooth" "$1"
}

status_json() {
    local show powered discovering devices_json
    show=$(bluetoothctl show 2>/dev/null || true)
    powered=false
    discovering=false
    grep -q 'Powered: yes' <<<"$show" && powered=true
    grep -q 'Discovering: yes' <<<"$show" && discovering=true
    devices_json='[]'

    while read -r prefix mac name; do
        [[ "$prefix" == "Device" && -n "${mac:-}" ]] || continue
        local info connected paired trusted battery
        info=$(bluetoothctl info "$mac" 2>/dev/null || true)
        connected=false
        paired=false
        trusted=false
        battery=-1
        grep -q 'Connected: yes' <<<"$info" && connected=true
        grep -q 'Paired: yes' <<<"$info" && paired=true
        grep -q 'Trusted: yes' <<<"$info" && trusted=true
        if grep -q 'Battery Percentage:' <<<"$info"; then
            battery=$(awk '/Battery Percentage:/ {gsub(/[()]/, "", $4); print $4; exit}' <<<"$info")
            [[ "$battery" =~ ^[0-9]+$ ]] || battery=-1
        fi

        devices_json=$(jq -cn \
            --argjson current "$devices_json" \
            --arg address "$mac" \
            --arg name "${name:-$mac}" \
            --argjson connected "$connected" \
            --argjson paired "$paired" \
            --argjson trusted "$trusted" \
            --argjson battery "$battery" \
            '$current + [{address: $address, name: $name, connected: $connected, paired: $paired, trusted: $trusted, battery: $battery}]')
    done < <(bluetoothctl devices 2>/dev/null || true)

    devices_json=$(jq -c 'sort_by((if .connected then 0 elif .paired then 1 else 2 end), (.name | ascii_downcase))' <<<"$devices_json")

    jq -cn \
        --argjson powered "$powered" \
        --argjson discovering "$discovering" \
        --argjson devices "$devices_json" \
        '{powered: $powered, discovering: $discovering, devices: $devices}'
}

case "${1:-status}" in
    status)
        status_json
        ;;
    toggle-power)
        if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
            bluetoothctl power off >/dev/null 2>&1 || notify_error "Impossible de désactiver l’adaptateur"
        else
            bluetoothctl power on >/dev/null 2>&1 || notify_error "Impossible d’activer l’adaptateur"
        fi
        ;;
    toggle-scan)
        if bluetoothctl show 2>/dev/null | grep -q 'Discovering: yes'; then
            bluetoothctl scan off >/dev/null 2>&1 || notify_error "Impossible d’arrêter la recherche"
        else
            bluetoothctl power on >/dev/null 2>&1 || {
                notify_error "Impossible d’activer l’adaptateur"
                exit 1
            }
            bluetoothctl --timeout 30 scan on >/dev/null 2>&1 || notify_error "Recherche Bluetooth impossible"
        fi
        ;;
    toggle-device)
        address="${2:-}"
        [[ -n "$address" ]] || exit 2
        if bluetoothctl info "$address" 2>/dev/null | grep -q 'Connected: yes'; then
            bluetoothctl disconnect "$address" >/dev/null 2>&1 || notify_error "Déconnexion impossible"
        elif bluetoothctl info "$address" 2>/dev/null | grep -q 'Paired: yes'; then
            bluetoothctl connect "$address" >/dev/null 2>&1 || notify_error "Connexion impossible"
        else
            bluetoothctl pair "$address" >/dev/null 2>&1 || {
                notify_error "Jumelage impossible"
                exit 1
            }
            bluetoothctl trust "$address" >/dev/null 2>&1 || true
            bluetoothctl connect "$address" >/dev/null 2>&1 || notify_error "Appareil jumelé, mais connexion impossible"
        fi
        ;;
    remove-device)
        address="${2:-}"
        [[ -n "$address" ]] || exit 2
        bluetoothctl disconnect "$address" >/dev/null 2>&1 || true
        bluetoothctl remove "$address" >/dev/null 2>&1 || notify_error "Suppression impossible"
        ;;
    *)
        printf 'Usage: %s {status|toggle-power|toggle-scan|toggle-device ADDRESS|remove-device ADDRESS}\n' "$0" >&2
        exit 2
        ;;
esac
