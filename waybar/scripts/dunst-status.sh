#!/bin/bash

paused=$(dunstctl is-paused)
waiting=$(dunstctl count waiting)

if [ $paused == "false" ]; then
    echo "{\"alt\":\"default\"}"
    exit 0
fi

if [ $waiting -eq 0 ]; then
    echo "{\"alt\":\"paused\"}"
    exit 0
fi

echo "{\"alt\":\"paused\",\"tooltip\":\"Messages waiting: $waiting\"}"
