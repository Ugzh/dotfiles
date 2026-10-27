#!/usr/bin/env bash
set -euo pipefail

dotfiles_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
inventory_root="$dotfiles_root/inventory"

if ! command -v mise >/dev/null 2>&1; then
  printf 'mise est requis : https://mise.jdx.dev/getting-started.html\n' >&2
  exit 1
fi

mise trust --yes "$dotfiles_root/mise.toml" >/dev/null
mise --cd "$dotfiles_root" dot apply
mise dot save
mise dot sync
mise dot pull

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

printf 'Dotfiles mise synchronisés et inventaires à jour.\n'
