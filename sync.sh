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
  swaylock
  systemd
  tealdeer
  theme
  tmux
  waybar
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
  starship.toml
  terminal-tools.md
)

personal_scripts=(
  apply-theme
  apply-wallpaper
  clipboard-history
  color-picker
  dope
  power-menu
  toggle-screen-recording
  toggle-theme
  waybar-calendar
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
  --exclude='*.wasm'
  --exclude=atuin-receipt.json
)

mkdir -p "$snapshot_root/.config" "$snapshot_root/.local/bin" "$snapshot_root/Pictures/Wallpapers"

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

if [[ -f "$source_root/Pictures/Wallpapers/wp-home.jpg" ]]; then
  rsync --archive "$source_root/Pictures/Wallpapers/wp-home.jpg" "$snapshot_root/Pictures/Wallpapers/wp-home.jpg"
fi

printf 'Snapshot mis à jour dans %s\n' "$snapshot_root"
printf 'Vérifie maintenant avec : git -C %q status --short\n' "$dotfiles_root"

