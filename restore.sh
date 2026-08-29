#!/usr/bin/env bash
set -euo pipefail

dotfiles_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_root="$dotfiles_root/home"
target_root="${HOME:?HOME is not set}"
apply=false
absolute_links=(
  .config/systemd/user/default.target.wants/codex-update-manager.service
  .config/systemd/user/skwd-daemon.service
  .config/systemd/user/sockets.target.wants/podman.socket
)

if [[ "${1:-}" == "--apply" ]]; then
  apply=true
elif [[ $# -gt 0 ]]; then
  printf 'Usage : %s [--apply]\n' "$0" >&2
  exit 2
fi

if ! command -v stow >/dev/null 2>&1; then
  printf 'GNU Stow est requis. Installe-le avec : sudo dnf install stow\n' >&2
  exit 1
fi

conflicts=()
while IFS= read -r -d '' source_path; do
  relative_path=${source_path#"$package_root"/}
  target_path="$target_root/$relative_path"

  if [[ -L "$target_path" ]]; then
    source_real=$(realpath -m "$source_path")
    target_real=$(realpath -m "$target_path")
    [[ "$source_real" == "$target_real" ]] || conflicts+=("$relative_path")
  elif [[ -e "$target_path" ]]; then
    conflicts+=("$relative_path")
  fi
done < <(find "$package_root" \( -type f -o -type l \) -print0)

if ! $apply; then
  if [[ ${#conflicts[@]} -eq 0 ]]; then
    printf 'Aucun conflit. Stow peut être appliqué directement.\n'
  else
    printf '%d fichier(s) seront sauvegardés avant la création des liens :\n' "${#conflicts[@]}"
    printf '  %s\n' "${conflicts[@]}"
  fi
  printf '\nPour appliquer : %s --apply\n' "$0"
  exit 0
fi

backup_root="$target_root/.dotfiles-backup/stow-$(date +%Y%m%d-%H%M%S)"
if [[ ${#conflicts[@]} -gt 0 ]]; then
  for relative_path in "${conflicts[@]}"; do
    target_path="$target_root/$relative_path"
    backup_path="$backup_root/$relative_path"
    mkdir -p "$(dirname -- "$backup_path")"
    mv -- "$target_path" "$backup_path"
  done
fi

stow \
  --dir="$dotfiles_root" \
  --target="$target_root" \
  --no-folding \
  --ignore='codex-update-manager\.service|skwd-daemon\.service|podman\.socket' \
  --restow \
  home

for relative_path in "${absolute_links[@]}"; do
  target_path="$target_root/$relative_path"
  if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
    mkdir -p "$(dirname -- "$target_path")"
    ln -s "$(readlink -- "$package_root/$relative_path")" "$target_path"
  fi
done

printf 'Dotfiles liés avec GNU Stow.\n'
if [[ ${#conflicts[@]} -gt 0 ]]; then
  printf 'Anciens fichiers sauvegardés dans %s\n' "$backup_root"
fi
