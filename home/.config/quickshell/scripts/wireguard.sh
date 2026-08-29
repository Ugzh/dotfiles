#!/usr/bin/env bash
set -u

PUBLIC_PROFILE="ugo-public"
GPU_PROFILE="ugo-gpu"

is_active() {
    nmcli -t -f NAME connection show --active 2>/dev/null | grep -Fxq "$1"
}

activate_profile() {
    local target="$1"
    [[ "$target" != "$PUBLIC_PROFILE" ]] && is_active "$PUBLIC_PROFILE" && nmcli connection down "$PUBLIC_PROFILE" >/dev/null 2>&1 || true
    [[ "$target" != "$GPU_PROFILE" ]] && is_active "$GPU_PROFILE" && nmcli connection down "$GPU_PROFILE" >/dev/null 2>&1 || true

    if nmcli --wait 15 connection up "$target" >/dev/null 2>&1; then
        notify-send -u low "WireGuard" "$target activé"
    else
        notify-send -u critical "WireGuard" "Impossible d'activer $target"
        return 1
    fi
}

disable_profile() {
    local profile="$1"
    if nmcli connection down "$profile" >/dev/null 2>&1; then
        notify-send -u low "WireGuard" "$profile désactivé"
    else
        notify-send -u critical "WireGuard" "Impossible de désactiver $profile"
        return 1
    fi
}

toggle_profile() {
    if is_active "$1"; then
        disable_profile "$1"
    else
        activate_profile "$1"
    fi
}

disconnect_all() {
    is_active "$PUBLIC_PROFILE" && disable_profile "$PUBLIC_PROFILE"
    is_active "$GPU_PROFILE" && disable_profile "$GPU_PROFILE"
    return 0
}

show_menu() {
    local public_mark="○"
    local gpu_mark="○"
    is_active "$PUBLIC_PROFILE" && public_mark="●"
    is_active "$GPU_PROFILE" && gpu_mark="●"

    local choice
    choice=$(printf '%s\n%s\n%s\n' \
        "$public_mark  $PUBLIC_PROFILE" \
        "$gpu_mark  $GPU_PROFILE" \
        "⏻  Désactiver tous les VPN" |
        fuzzel --dmenu --prompt='VPN  ' --lines=3 --width=32) || exit 0

    case "$choice" in
        *"$PUBLIC_PROFILE") toggle_profile "$PUBLIC_PROFILE" ;;
        *"$GPU_PROFILE") toggle_profile "$GPU_PROFILE" ;;
        *"Désactiver tous les VPN") disconnect_all ;;
    esac
}

case "${1:-menu}" in
    toggle-public) toggle_profile "$PUBLIC_PROFILE" ;;
    toggle-gpu) toggle_profile "$GPU_PROFILE" ;;
    disconnect) disconnect_all ;;
    menu) show_menu ;;
    *) printf 'Usage: %s {toggle-public|toggle-gpu|disconnect|menu}\n' "$0" >&2; exit 2 ;;
esac
