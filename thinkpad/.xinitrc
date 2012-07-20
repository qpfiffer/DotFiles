#!/bin/bash
eval $(cat ~/.fehbg) &
xrdb ~/.Xresources &
firefox &
# To get the trackpoint scroll stuff going:
~/src/DotFiles/thinkpad/xinput_trackpoint.sh  > /dev/null &
while true
do
    LOCALTIME=$(~/src/DotFiles/hex_time_bash.sh)

	xsetroot -name "$LOCALTIME"
	sleep 5s
done &

exec dwm
