#!/bin/bash

# Укажите свой город и API ключ
CITY="Moscow"
API_KEY="ваш_api_ключ_openweathermap"

# Получаем данные
weather_data=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=$CITY&appid=$API_KEY&units=metric")

# Извлекаем температуру и описание
TEMP=$(echo $weather_data | jq -r ".main.temp" | xargs printf "%.0f")
DESC=$(echo $weather_data | jq -r ".weather[0].main")

# Выводим результат
echo "$CITY $TEMP°C $DESC"