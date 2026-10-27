#!/usr/bin/env bash
set -euo pipefail

dotfiles_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
apply=false

if [[ "${1:-}" == "--apply" ]]; then
  apply=true
elif [[ $# -gt 0 ]]; then
  printf 'Usage : %s [--apply]\n' "$0" >&2
  exit 2
fi

if ! command -v mise >/dev/null 2>&1; then
  printf 'mise est requis : https://mise.jdx.dev/getting-started.html\n' >&2
  exit 1
fi

mise trust --yes "$dotfiles_root/mise.toml" >/dev/null

if ! $apply; then
  mise --cd "$dotfiles_root" dot apply --dry-run
  printf '\nPour appliquer : %s --apply\n' "$0"
  exit 0
fi

mise --cd "$dotfiles_root" dot apply
mise bootstrap services apply
printf 'Dotfiles desktop déployés et surveillance mise activée.\n'
