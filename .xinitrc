#!/bin/bash
eval $(cat ~/.fehbg) &
#google-musicmanager &
xrdb ~/.Xresources &
eval `ssh-agent -t 21600`
uzbl-tabbed &
while true
do
    LOCALTIME=$(~/src/DotFiles/hex_time_bash.sh)

	xsetroot -name "$LOCALTIME"
	sleep 5s
done &

exec dwm
