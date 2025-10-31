#!/bin/bash

paused=$(dunstctl is-paused)
waiting=$(dunstctl count waiting)

if [ $paused == "true" ]; then
    alt="paused"

    if [ $waiting != 0 ]; then
        tooltip="Messages waiting: $waiting"
    fi
fi

echo "{\"alt\":\"$alt\",\"tooltip\":\"$tooltip\"}"
