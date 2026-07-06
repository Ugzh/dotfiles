#!/bin/bash
sleep 1
# Tue les processus de portal qui pourraient bloquer le verrouillage
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-gtk
killall -e xdg-desktop-portal

# Relance proprement les services
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &
