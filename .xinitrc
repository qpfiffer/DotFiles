#!/bin/bash
eval $(cat ~/.fehbg) &
#google-musicmanager &
xrdb ~/.Xresources &
#imwheel & # Because chromium scrolls like a fucking dead person
#wine ~/.wine/drive_c/Program\ Files/Steam/steam.exe &
#pidgin &
#/usr/bin/dropbox start &
#chromium-browser &
firefox &
while true
do
    LOCALTIME=$(~/src/DotFiles/hex_time_bash.sh)

	xsetroot -name "$LOCALTIME"
	sleep 5s
done &

exec dwm
