#!/bin/bash

if pgrep -f "^gpu-screen-recorder" >/dev/null; then
  echo '{"alt": "active", "tooltip": "Stop recording", "class": "active"}'
else
  echo '{"text": ""}'
fi
