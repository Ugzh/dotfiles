#!/usr/bin/env bash
set -euo pipefail

dotfiles_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
snapshot_root="$dotfiles_root/home"
source_root="${HOME:?HOME is not set}"

config_dirs=(
  atuin
  btop
  cava
  dust
  environment.d
  fish
  fuzzel
  gtk-3.0
  gtk-4.0
  gtklock
  kitty
  lazygit
  mako
  mise
  niri
  nvim
  pitchfork
  posting
  procps
  quickshell
  spicetify
  swaylock
  systemd
  tealdeer
  theme
  theme-picker
  tmux
  waybar
  xdg-desktop-portal
  yazi
  zathura
  zellij
)

root_files=(
  .gitconfig
  .harlequin.toml
  .tmux.conf
  .zshrc
)

config_files=(
  mimeapps.list
  starship.toml
  starship.toml.tmpl
  terminal-tools.md
)

personal_scripts=(
  apply-theme
  apply-wallpaper
  clipboard-history
  color-picker
  dope
  dope-changelog.md
  power-menu
  theme-menu
  theme-picker-toggle
  toggle-screen-recording
  toggle-theme
  wallpaper-menu
  waybar-calendar
)

local_applications=(
  Vial.desktop
  mongodb-compass.desktop
  obsidian.desktop
)

wallpapers=(
  catppuccin.png
  dragon.jpg
  gruvbox_dark.jpg
  gruvbox_light.jpg
  wp-home.jpg
)

rsync_common=(
  --archive
  --delete
  --exclude=.git/
  --exclude=.agents/
  --exclude=.codex/
  --exclude=node_modules/
  --exclude=__pycache__/
  --exclude='*.log'
  --exclude='*.bak'
  --exclude='*.backup-*'
  --exclude='*.wasm'
  --exclude=atuin-receipt.json
  --exclude=CustomApps/
  --exclude=Extensions/
)

mkdir -p \
  "$snapshot_root/.config" \
  "$snapshot_root/.local/bin" \
  "$snapshot_root/.local/share/applications" \
  "$snapshot_root/Pictures/Wallpapers" \
  "$dotfiles_root/inventory"

for config_dir in "${config_dirs[@]}"; do
  source_path="$source_root/.config/$config_dir"
  destination_path="$snapshot_root/.config/$config_dir"
  if [[ -d "$source_path" ]]; then
    mkdir -p "$destination_path"
    rsync "${rsync_common[@]}" "$source_path/" "$destination_path/"
  fi
done

for root_file in "${root_files[@]}"; do
  if [[ -f "$source_root/$root_file" ]]; then
    rsync --archive "$source_root/$root_file" "$snapshot_root/$root_file"
  fi
done

for config_file in "${config_files[@]}"; do
  if [[ -f "$source_root/.config/$config_file" ]]; then
    rsync --archive "$source_root/.config/$config_file" "$snapshot_root/.config/$config_file"
  fi
done

for personal_script in "${personal_scripts[@]}"; do
  if [[ -f "$source_root/.local/bin/$personal_script" ]]; then
    rsync --archive "$source_root/.local/bin/$personal_script" "$snapshot_root/.local/bin/$personal_script"
  fi
done

for local_application in "${local_applications[@]}"; do
  if [[ -f "$source_root/.local/share/applications/$local_application" ]]; then
    rsync \
      --archive \
      "$source_root/.local/share/applications/$local_application" \
      "$snapshot_root/.local/share/applications/$local_application"
  fi
done

for wallpaper in "${wallpapers[@]}"; do
  if [[ -f "$source_root/Pictures/Wallpapers/$wallpaper" ]]; then
    rsync \
      --archive \
      "$source_root/Pictures/Wallpapers/$wallpaper" \
      "$snapshot_root/Pictures/Wallpapers/$wallpaper"
  fi
done

if command -v dnf >/dev/null 2>&1; then
  if ! dnf repoquery --userinstalled --qf '%{name}\n' 2>/dev/null \
    | sort -u > "$dotfiles_root/inventory/dnf-userinstalled.txt"; then
    rm -f "$dotfiles_root/inventory/dnf-userinstalled.txt"
    printf 'Avertissement : inventaire DNF indisponible.\n' >&2
  fi
fi

if command -v flatpak >/dev/null 2>&1; then
  if ! flatpak list --app --columns=application 2>/dev/null \
    | sort -u > "$dotfiles_root/inventory/flatpak-apps.txt"; then
    rm -f "$dotfiles_root/inventory/flatpak-apps.txt"
    printf 'Avertissement : inventaire Flatpak indisponible.\n' >&2
  fi
fi

if command -v systemctl >/dev/null 2>&1; then
  if ! systemctl --user list-unit-files --state=enabled --no-legend 2>/dev/null \
    | awk '{print $1}' \
    | sort -u > "$dotfiles_root/inventory/user-services.txt"; then
    rm -f "$dotfiles_root/inventory/user-services.txt"
    printf 'Avertissement : inventaire des services utilisateur indisponible.\n' >&2
  fi
fi

printf 'Snapshot mis à jour dans %s\n' "$snapshot_root"
printf 'Vérifie maintenant avec : git -C %q status --short\n' "$dotfiles_root"
