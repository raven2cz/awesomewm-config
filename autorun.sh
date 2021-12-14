#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run /usr/lib/kactivitymanagerd
#run /use/lib/polkit-kde-authentication-agent-1
run /usr/lib/pam_kwallet_init
run nm-applet
run pamac-tray
synology-drive start
run parcellite
run clipmenud
run volctl
run /usr/bin/emacs --daemon
run ~/.config/conky/start_conky ~/.config/conky/MX-CoreBlue/conkyrc2core 
run remmina -i
run picom --experimental-backends --config $HOME/.config/picom/picom.conf
