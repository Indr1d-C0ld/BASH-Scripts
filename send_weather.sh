#!/bin/bash

# Variabili
API_KEY="OPENWEATHER API KEY"
CITY_ID="CITY ID"  # Puoi ottenere l'ID città da OpenWeatherMap
TOKEN="MY BOT TOKEN"
CHAT_ID="CHANNEL ID"

# Ottieni i dati meteo
WEATHER=$(curl -s "http://api.openweathermap.org/data/2.5/weather?id=$CITY_ID&appid=$API_KEY&units=metric")

# Estrai le informazioni necessarie
TEMP=$(echo $WEATHER | jq '.main.temp')
DESCRIPTION=$(echo $WEATHER | jq -r '.weather[0].description')
CITY=$(echo $WEATHER | jq -r '.name')

# Messaggio da inviare
MESSAGE="Meteo a $CITY: $TEMP°C, $DESCRIPTION"

# Invia messaggio a Telegram
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE"
