#!/usr/bin/env bash
updates=$(dnf -q check-update 2>/dev/null | awk 'NF >= 3 && $1 !~ /^Obsoleting/ {count++} END {print count + 0}')
if (( updates > 0 )); then
    printf '󰏖 %s\n' "$updates"
fi
