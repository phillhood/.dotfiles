#!/usr/bin/env bash
confirm() {
  local answer
  answer=$(printf '%s\n' "  No" "  Yes" | walker --dmenu -t power -n -H -p "$1?")
  [[ "$answer" == *Yes ]]
}

chosen=$(printf '%s\n' \
  "  Lock" \
  "  Logout" \
  "  Suspend" \
  "  Reboot" \
  "  Shutdown" \
  | walker --dmenu -t power -n -H -p "Power")

case "$chosen" in
  *Lock)     hyprlock ;;
  *Logout)   hyprctl dispatch exit ;;
  *Suspend)  systemctl suspend ;;
  *Reboot)   confirm "Reboot" && systemctl reboot ;;
  *Shutdown) confirm "Shutdown" && systemctl poweroff ;;
esac
