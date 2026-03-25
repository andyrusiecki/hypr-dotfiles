#!/bin/sh

governor=$(cpufreqctl.auto-cpufreq -g | tr ' ' '\n' | head -n 1)

jq -n --unbuffered --compact-output \
  --arg governor "$governor" \
  '{alt: $governor, text: $governor}'
