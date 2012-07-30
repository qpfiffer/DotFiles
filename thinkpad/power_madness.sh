#!/bin/bash

ethtool -s eth0 autoneg off speed 100
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
