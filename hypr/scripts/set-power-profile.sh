#!/bin/bash

# Get battery capacity
CAPACITY=$(cat /sys/class/power_supply/BAT*/capacity)

# Get status (Charging/Discharging)
STATUS=$(cat /sys/class/power_supply/BAT*/status)

if [ "$STATUS" == "Discharging" ]; then
  if [ "$CAPACITY" -le 20 ]; then
    tuned-adm profile laptop-battery-powersave
  elif [ "$CAPACITY" -le 50 ]; then
    tuned-adm profile laptop-ac-powersave
  fi
else
  # If charging, always go back to performance or balanced
  tuned-adm profile balanced
fi
