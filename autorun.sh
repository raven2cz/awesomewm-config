#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run /usr/lib/kactivitymanagerd
run /usr/bin/kglobalaccel5
run nm-applet
run pamac-tray
if ! pgrep -f cloud-drive-ui; then synology-drive start; fi
run parcellite
run clipmenud
run volctl
run /usr/bin/emacs --daemon
run ~/.config/conky/start_conky ~/.config/conky/MX-CoreBlue/conkyrc2core 
run remmina -i
run picom --experimental-backends --config $HOME/.config/picom/picom.conf
run mpv --no-video ~/.config/awesome/fishlive/sounds/startup-snd-1.mp3
