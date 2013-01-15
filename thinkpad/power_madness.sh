#!/bin/bash

ethtool -s eth0 autoneg off speed 100
echo 0 > /sys/devices/platform/thinkpad_acpi/bluetooth_enable
