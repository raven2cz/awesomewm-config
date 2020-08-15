#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
#run /use/lib/polkit-kde-authentication-agent-1
run /usr/lib/pam_kwallet_init
run nm-applet
run pamac-tray
run alttab -mk Control_L -pk h -nk l -fg "#d58681" -bg "#4a4a4a" -frame "#eb564d" -t 128x150 -i 127x64
run copyq
run xautolock -time 3 -locker blurlock
run clipit
run volumeicon
run conky -c ~/.config/conky
run remmina -i
run picom --experimental-backends --config $HOME/.config/picom/picom.conf

