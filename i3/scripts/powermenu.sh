#!/bin/bash

selected=$(echo -e " Lock\n Logout\n Suspend\n Hibernate\n Reboot\n Shutdown" | rofi -dmenu -i -p "Power" -theme ~/.config/rofi/powermenu.rasi)

case $selected in
  *Lock)      loginctl lock-session ;;
  *Logout)    i3-msg exit ;;
  *Suspend)   systemctl suspend ;;
  *Hibernate) systemctl hibernate ;;
  *Reboot)    systemctl reboot ;;
  *Shutdown)  systemctl poweroff ;;
esac
