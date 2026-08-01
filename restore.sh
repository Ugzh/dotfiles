#!/usr/bin/env bash
set -euo pipefail

dotfiles_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
snapshot_root="$dotfiles_root/home"
destination_root="${HOME:?HOME is not set}"

if [[ "${1:-}" != "--apply" ]]; then
  printf 'Aucune modification effectuée. Aperçu des fichiers à restaurer :\n\n'
  rsync --archive --dry-run --itemize-changes "$snapshot_root/" "$destination_root/"
  printf '\nPour appliquer : %s --apply\n' "$0"
  exit 0
fi

backup_root="$destination_root/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_root"

rsync \
  --archive \
  --itemize-changes \
  --backup \
  --backup-dir="$backup_root" \
  "$snapshot_root/" \
  "$destination_root/"

printf 'Configuration restaurée. Fichiers remplacés sauvegardés dans %s\n' "$backup_root"

