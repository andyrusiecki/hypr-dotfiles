#!/bin/bash

current_hour=$(($(date +'%-H') - 2))
curl -s "https://wttr.in/?format=j1" | \
jq -r -c '{
  "text": .current_condition[0].temp_F + "°",
  "alt": .current_condition[0].weatherCode,
  "tooltip":
    "<b>" + .current_condition[0].weatherDesc[0].value + " " + .current_condition[0].temp_F + "°F</b>\n" +
    "Feels like: " + .current_condition[0].FeelsLikeF + "°F\n" +
    "Wind: " + .current_condition[0].windspeedMiles + " mph " + .current_condition[0].winddir16Point + "\n" +
    "Humidity: " + .current_condition[0].humidity + "%\n" +
    (
      [
        .weather | to_entries[] |
        "\n<b>" + (
          if .key == 0 then
            "Today, "
          elif .key == 1 then
            "Tomorrow, "
          else
            ""
          end
        ) + .value.date + "</b>\n" +
        " " + .value.maxtempF + "°  " + .value.mintempF + "° " +
        "󰖜 " + .value.astronomy[0].sunrise + " 󰖛 " + .value.astronomy[0].sunset + "\n" +
        (
          [
            .value.hourly | to_entries[] |
            (
              if .key == 0 and(.value.time | tonumber) < '$current_hour' then
                ""
              else
                .value.time + " " + .value.weatherCode + " " + .value.FeelsLikeF + "° " + .value.weatherDesc[0].value + "\n"
              end
            )
          ] | join("")
        )
      ] | join("")
    )
}'
