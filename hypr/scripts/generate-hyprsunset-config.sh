#!/bin/bash

weather_json=$(mktemp)
curl -s "https://wttr.in/?format=j1" -o "$weather_json"
sunrise=$(jq -r -c '.weather[0].astronomy[0].sunrise' $weather_json)
sunset=$(jq -r -c '.weather[0].astronomy[0].sunset' $weather_json)

rm $weather_json

if [ -z "$sunrise" ] || [ -z "$sunset" ]; then
  echo "Error: Unable to fetch sunrise/sunset times."
  echo "Using existing configuration if available."
  exit 0
fi

transition_time_min=60
transition_time_neg_offset=30
transition_stages=10

daytime_temp=6000
nighttime_temp=3000

config_file="$HOME/.config/hypr/hyprsunset.conf"

echo "Generating hyprsunset config file at $config_file"
echo "- Sunrise: $sunrise"
echo "- Sunset: $sunset"
echo "- Daytime Temp: $daytime_temp K"
echo "- Nighttime Temp: $nighttime_temp K"
echo "- Transition Time: $transition_time_min min"
echo "- Transition Time Offset: -$transition_time_neg_offset min"
echo "- Transition Stages: $transition_stages"

daytime_config="# Daytime Profile\n\
# - sunrise at: $sunrise\n\
# - transition starts at: $(date -d "$sunrise today - $transition_time_neg_offset minutes" '+%0I:%M %p')\n\
# - temp to $daytime_temp K over $transition_time_min min in $transition_stages stages\n"

nighttime_config="# Nighttime Profile\n\
# - sunset at: $sunset\n\
# - transition starts at: $(date -d "$sunset today - $transition_time_neg_offset minutes" '+%0I:%M %p')\n\
# - temp to $nighttime_temp K over $transition_time_min min in $transition_stages stages\n"

for (( i=1; i <= $transition_stages; i++ )); do
  time_offset=$(( ($i - 1) * $transition_time_min / ($transition_stages - 1) - $transition_time_neg_offset ))
  temp_offset=$(( $i * ($daytime_temp - $nighttime_temp) / $transition_stages ))

  daytime_config+="\n# Daytime Stage $i \n\
profile {\n\
  time = $(date -d "$sunrise today + $time_offset minutes" +"%_H:%M")\n\
  temperature = $(($nighttime_temp + $temp_offset))\n\
}\n"

  nighttime_config+="\n# Nighttime Stage $i \n\
profile {\n\
  time = $(date -d "$sunset today + $time_offset minutes" +"%_H:%M")\n\
  temperature = $(($daytime_temp - $temp_offset))\n\
}\n"
done

config_content+="# Hyprsunset auto-generated config file\n\n$daytime_config\n$nighttime_config"

if [ -f $config_file ]; then
  rm $config_file
fi

echo -e "$config_content" > $config_file
