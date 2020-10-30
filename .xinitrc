#!/bin/sh
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
numlockx &
setxkbmap -layout "us,cz" -option "grp:alt_shift_toggle" -variant ",qwerty" &
xrdb -merge ~/.Xresources
export QT_STYLE_OVERRIDE=kvantum
#export QT_QPA_PLATFORMTHEME="qt5ct"
export DESKTOP_SESSION=plasma
#export DESKTOP_SESSION=gnome
export XDG_CURRENT_DESKTOP=KDE
#export XDG_CURRENT_DESKTOP=GNOME
export XDG_CONFIG_HOME=$HOME/.config
export EDITOR=vim

# clipmenu rofi support
export CM_LAUNCHER=rofi
export CM_HISTLENGTH=50
export CM_DIR=~/.config/clipmenu

# Here AwesomeWM is kept as default
session=${1:-awesome}

case $session in
    i3|i3wm)
        exec i3
        ;;
    awesome)
        exec awesome
        ;;
    kde)
        exec startplasma-x11
        ;;
    gnome)
        export XDG_CURRENT_DESKTOP=GNOME
        export DESKTOP_SESSION=gnome
        exec gnome-session
        ;;
    qtile)
        exec qtile
        ;;
    bspwm)
        exec bspwm
        ;;
    herbstluftwm)
        exec herbstluftwm
        ;;
    xfce|xfce4)
        exec startxfce4
        ;;
    # No known session, try to run it as command
    *)
        exec $1
        ;;
esac
