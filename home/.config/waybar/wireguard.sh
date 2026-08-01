#!/usr/bin/env bash

PUBLIC_PROFILE="ugo-public"
GPU_PROFILE="ugo-gpu"

is_active() {
  nmcli -t -f NAME connection show --active 2>/dev/null | grep -Fxq "$1"
}

refresh_waybar() {
  pkill -RTMIN+8 waybar 2>/dev/null || true
}

activate_profile() {
  local target="$1"

  if [ "$target" != "$PUBLIC_PROFILE" ] && is_active "$PUBLIC_PROFILE"; then
    nmcli connection down "$PUBLIC_PROFILE" >/dev/null 2>&1 || true
  fi

  if [ "$target" != "$GPU_PROFILE" ] && is_active "$GPU_PROFILE"; then
    nmcli connection down "$GPU_PROFILE" >/dev/null 2>&1 || true
  fi

  if ! nmcli --wait 15 connection up "$target" >/dev/null 2>&1; then
    notify-send -u critical "WireGuard" "Impossible d'activer $target"
    return 1
  fi

  notify-send -u low "WireGuard" "$target activé"
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
  local profile="$1"

  if is_active "$profile"; then
    disable_profile "$profile"
  else
    activate_profile "$profile"
  fi
}

open_menu() {
  local public_mark="○"
  local gpu_mark="○"
  local choice

  is_active "$PUBLIC_PROFILE" && public_mark="●"
  is_active "$GPU_PROFILE" && gpu_mark="●"

  choice="$(printf '%s\n%s\n%s\n' \
    "$public_mark  $PUBLIC_PROFILE" \
    "$gpu_mark  $GPU_PROFILE" \
    "⏻  Désactiver tous les VPN" | \
    fuzzel --dmenu --prompt='VPN  ' --lines=3 --width=32)" || return 0

  case "$choice" in
    *"$PUBLIC_PROFILE")
      toggle_profile "$PUBLIC_PROFILE"
      ;;
    *"$GPU_PROFILE")
      toggle_profile "$GPU_PROFILE"
      ;;
    *"Désactiver tous les VPN")
      is_active "$PUBLIC_PROFILE" && disable_profile "$PUBLIC_PROFILE"
      is_active "$GPU_PROFILE" && disable_profile "$GPU_PROFILE"
      ;;
  esac
}

case "${1:-status}" in
  menu)
    open_menu
    refresh_waybar
    ;;
  status)
    ;;
  *)
    notify-send -u normal "WireGuard" "Action inconnue : $1"
    exit 2
    ;;
esac

if is_active "$PUBLIC_PROFILE"; then
  printf '{"text":" P","class":"active-public","tooltip":"WireGuard : ugo-public\\nClic gauche : choisir un VPN\\nClic droit : connexions"}\n'
elif is_active "$GPU_PROFILE"; then
  printf '{"text":" G","class":"active-gpu","tooltip":"WireGuard : ugo-gpu\\nClic gauche : choisir un VPN\\nClic droit : connexions"}\n'
else
  printf '{"text":"","class":"inactive","tooltip":"WireGuard désactivé\\nClic gauche : choisir un VPN\\nClic droit : connexions"}\n'
fi
