#/!bin/bash

CITY=Borovichi

WEATHER=$(curl -s "wttr.in/$CITY?format=3")

if [ -z "$WEATHER" ]; then
    echo "WEATHER UNAVAILABLE"
else 
    echo "$WEATHER"
fi
