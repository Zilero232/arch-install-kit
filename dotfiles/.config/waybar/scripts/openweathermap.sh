#!/usr/bin/env bash
# Prints current weather ("icon temp feels-like") from OpenWeatherMap for custom/weather.
# Credentials live outside the repo in ~/.config/waybar/weather.env:
#   OPENWEATHER_API_KEY=...
#   OPENWEATHER_CITY_ID=...

set -euo pipefail

readonly ENV_FILE="$HOME/.config/waybar/weather.env"
readonly UNITS="metric"
readonly LANGUAGE="en"
readonly API_URL="https://api.openweathermap.org/data/2.5/weather"

# Nerd Font icon for an OpenWeatherMap condition
# Args: <main condition> <day|night> <detailed description>
weather_icon() {
    local condition=$1 period=$2 description=$3

    case "$condition" in
        Clear)
            if [[ "$period" == "day" ]]; then echo "󰖙"; else echo "󰖔"; fi
            ;;
        Clouds)
            case "$description" in
                "few clouds" | "scattered clouds") echo "󰖕" ;;
                *) echo "󰖐" ;;
            esac
            ;;
        Rain)
            if [[ "$description" == *light* ]]; then echo "󰖖"; else echo "󰖗"; fi
            ;;
        Drizzle) echo "󰖖" ;;
        Thunderstorm) echo "󰖓" ;;
        Snow) echo "󰖘" ;;
        Mist | Fog | Haze) echo "󰖑" ;;
        *) echo "󰖜" ;;
    esac
}

fetch_weather() {
    local api_key=$1 city_id=$2
    curl -sf --max-time 10 \
        "$API_URL?id=$city_id&appid=$api_key&units=$UNITS&lang=$LANGUAGE" || true
}

# One tab-separated line: temp feels_like condition description sunrise sunset.
# Empty output when a numeric field is missing; no field is empty (IFS=tab would merge it).
parse_weather() {
    jq -r '
        [.main.temp, .main.feels_like, .sys.sunrise, .sys.sunset] as $nums
        | if ($nums | all(type == "number")) then
            [.main.temp, .main.feels_like,
             (.weather[0].main // "Unknown"), (.weather[0].description // "-"),
             .sys.sunrise, .sys.sunset] | @tsv
          else empty end
    ' <<<"$1" 2>/dev/null || true
}

round() {
    LC_ALL=C printf "%.0f" "$1"
}

main() {
    if [[ -f "$ENV_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$ENV_FILE"
    fi

    local api_key="${OPENWEATHER_API_KEY:-}" city_id="${OPENWEATHER_CITY_ID:-}"
    if [[ -z "$api_key" || -z "$city_id" ]]; then
        echo "󰖐" # not configured: neutral icon only
        exit 0
    fi

    # Offline, bad key or malformed reply: show a placeholder instead of failing
    local parsed
    parsed=$(parse_weather "$(fetch_weather "$api_key" "$city_id")")
    if [[ -z "$parsed" ]]; then
        echo "󰖙 Weather unavailable"
        exit 0
    fi

    local temp feels_like condition description sunrise sunset now period="day"
    IFS=$'\t' read -r temp feels_like condition description sunrise sunset <<<"$parsed"
    now=$(date +%s)

    if [[ "$now" -lt "$sunrise" || "$now" -gt "$sunset" ]]; then
        period="night"
    fi

    echo "$(weather_icon "$condition" "$period" "$description")" \
        "$(round "$temp")°C 󰤾 $(round "$feels_like")°C"
}

main "$@"
