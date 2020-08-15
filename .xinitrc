eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
numlockx &
setxkbmap -layout "us,cz" -option "grp:alt_shift_toggle" -variant ",qwerty" &
xrdb -merge ~/.Xresources
export QT_STYLE_OVERRIDE=kvantum
export QT_QPA_PLATFORMTHEME="qt5ct"
export DESKTOP_SESSION=plasma
#export DESKTOP_SESSION=gnome
export XDG_CURRENT_DESKTOP=KDE
#export XDG_CURRENT_DESKTOP=GNOME
export XDG_CONFIG_HOME=$HOME/.config
export EDITOR=vim
#herbstluftwm
#exec i3
exec awesome
#exec bspwm
#exec qtile
#exec gnome-session
#exec startplasma-x11
#exec chamfer -l --config=/usr/share/chamfer/config/config.py --shader-path=/usr/share/chamfer/shaders/
#exec chamfer -n --config=/usr/share/chamfer/config/config.py
#exec stdbuf -oL -eL | exec chamfer --config=/usr/share/chamfer/config/config.py --shader-path=/usr/share/chamfer/shaders/ > /tmp/log 2>&1


