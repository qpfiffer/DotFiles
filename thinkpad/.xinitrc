#!/bin/bash
urxvtd -q -f -o &
eval $(cat ~/.fehbg) &
xrdb ~/.Xresources &
eval `ssh-agent -t 28800`
firefox &
# To get the trackpoint scroll stuff going:
~/src/DotFiles/thinkpad/xinput_trackpoint.sh  > /dev/null &
syndaemon -t -k -i 2 -d &
# At some point arch broke my natural scroll settings in synaptics
synclient VertScrollDelta=-107 &
synclient HorizScrollDelta=-107 &
batt() {
      FULL=`cat /sys/class/power_supply/BAT0/energy_full`
      PRESENT=`cat /sys/class/power_supply/BAT0/present`
      CHARGE=`cat /sys/class/power_supply/BAT0/energy_now`
      STATUS=`cat /sys/class/power_supply/BAT0/status`
    if test "$PRESENT" != "0" ; then
      CHARGE=$((${CHARGE}*100/${FULL}))
      case $STATUS in
        Full)
          SIGN="=";;
        Charging)
          SIGN="+";;
        Discharging)
          SIGN="-";;
      esac
      echo "BAT0: %${CHARGE}${SIGN}"
    else
      echo " AC"
    fi
}
while true
do
    LOCALTIME=$(~/src/DotFiles/hex_time_bash.sh)
    BATTERY=`batt`
    xsetroot -name "`batt` | $LOCALTIME"
    sleep 5s
done &

exec dwm
