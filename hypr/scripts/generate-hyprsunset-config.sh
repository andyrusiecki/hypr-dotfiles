#!/bin/bash

weather_json=$(curl -s "https://wttr.in/?format=j1")
sunrise=$(echo "$weather_json" | jq -r -c '.weather[0].astronomy[0].sunrise')
sunset=$(echo "$weather_json" | jq -r -c '.weather[0].astronomy[0].sunset')

transition_time_min=60
transition_stages=5

daytime_temp=6000
nighttime_temp=3000

config_file="$HOME/.config/hypr/hyprsunset.conf"

echo "Generating hyprsunset config file at $config_file"
echo "- Sunrise: $sunrise"
echo "- Sunset: $sunset"
echo "- Daytime Temp: $daytime_temp K"
echo "- Nighttime Temp: $nighttime_temp K"
echo "- Transition Time: $transition_time_min min"
echo "- Transition Stages: $transition_stages"

daytime_config="# Daytime Profile\n\
# - starts at: $sunrise\n\
# - temp to $daytime_temp K over $transition_time_min min in $transition_stages stages\n"

nighttime_config="# Nighttime Profile\n\
# - starts at: $sunset\n\
# - temp to $nighttime_temp K over $transition_time_min min in $transition_stages stages\n"

for (( i=0; i <= $transition_stages; i++ )); do
  time_offset=$(( $i * $transition_time_min / $transition_stages ))
  temp_offset=$(( ($i + 1) * ($daytime_temp - $nighttime_temp) / ($transition_stages + 1) ))

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
