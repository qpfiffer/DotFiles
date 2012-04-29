#!/bin/bash
eval $(cat ~/.fehbg) &
#google-musicmanager &
imwheel & # Because chromium scrolls like a fucking dead person
wine ~/.wine/drive_c/Program\ Files/Steam/steam.exe &
pidgin &
/usr/bin/dropbox start &
chromium-browser &
while true
do
	LOCALTIME=$(date)

	xsetroot -name "$LOCALTIME"
	sleep 5s
done &

exec dwm
