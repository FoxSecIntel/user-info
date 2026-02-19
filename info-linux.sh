#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  info-linux.sh [--deep] [--max-history N]

Options:
  --deep            Enable heavier checks (open files, SUID/SGID on /home)
  --max-history N   Number of history lines to show (default: 10)
  -h, --help        Show help
EOF
}

deep=false
max_history=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deep) deep=true; shift ;;
    --max-history)
      shift
      [[ $# -gt 0 ]] || { echo "Missing value for --max-history"; exit 1; }
      max_history="$1"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

[[ "$max_history" =~ ^[0-9]+$ ]] || { echo "--max-history must be numeric"; exit 1; }

section() {
  echo
  echo "################################################################################"
  echo "$1"
}

safe_run() {
  local cmd="$1"
  bash -c "$cmd" 2>/dev/null || echo "(unavailable)"
}

section "Reference"
date
hostname
whoami
id

section "Logged-in users"
safe_run "who"

section "Last logins (10)"
safe_run "last -Faiwx -n 10"

section "Accounts with UID 0"
safe_run "awk -F: '\$3==0 {print}' /etc/passwd"

section "/etc/passwd (sorted by UID)"
safe_run "sort -nk3 -t: /etc/passwd"

section "Crontab (current user)"
safe_run "crontab -l"

section "Bash history (last ${max_history})"
if [[ -r "$HOME/.bash_history" ]]; then
  tail -n "$max_history" "$HOME/.bash_history"
else
  echo "(no readable ~/.bash_history)"
fi

section "Large files in HOME (>10MB)"
safe_run "find '$HOME' -type f -size +10M -print | head -n 200"

if $deep; then
  section "Open files for current user (deep)"
  if command -v lsof >/dev/null 2>&1; then
    safe_run "lsof -u \"$(whoami)\" | head -n 300"
  else
    echo "lsof not installed"
  fi

  section "SUID files under /home (deep)"
  safe_run "find /home -xdev -type f -perm -4000 -print"

  section "SGID files under /home (deep)"
  safe_run "find /home -xdev -type f -perm -2000 -print"
fi
