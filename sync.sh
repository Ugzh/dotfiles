#!/usr/bin/env bash
set -euo pipefail

dotfiles_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_root="${HOME:?HOME is not set}"
inventory_root="$dotfiles_root/inventory"
package_root="$dotfiles_root/home"
absolute_links=(
  .config/systemd/user/default.target.wants/codex-update-manager.service
  .config/systemd/user/skwd-daemon.service
  .config/systemd/user/sockets.target.wants/podman.socket
)

if ! command -v stow >/dev/null 2>&1; then
  printf 'GNU Stow est requis. Installe-le avec : sudo dnf install stow\n' >&2
  exit 1
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

mkdir -p "$inventory_root"

if command -v dnf >/dev/null 2>&1; then
  if ! dnf repoquery --userinstalled --qf '%{name}\n' 2>/dev/null \
    | sort -u > "$inventory_root/dnf-userinstalled.txt"; then
    rm -f "$inventory_root/dnf-userinstalled.txt"
    printf 'Avertissement : inventaire DNF indisponible.\n' >&2
  fi
fi

if command -v flatpak >/dev/null 2>&1; then
  if ! flatpak list --app --columns=application 2>/dev/null \
    | sort -u > "$inventory_root/flatpak-apps.txt"; then
    rm -f "$inventory_root/flatpak-apps.txt"
    printf 'Avertissement : inventaire Flatpak indisponible.\n' >&2
  fi
fi

if command -v systemctl >/dev/null 2>&1; then
  if ! systemctl --user list-unit-files --state=enabled --no-legend 2>/dev/null \
    | awk '{print $1}' \
    | sort -u > "$inventory_root/user-services.txt"; then
    rm -f "$inventory_root/user-services.txt"
    printf 'Avertissement : inventaire des services utilisateur indisponible.\n' >&2
  fi
fi

printf 'Liens Stow et inventaires à jour.\n'
