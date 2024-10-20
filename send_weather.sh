#!/bin/bash

# Variabili da configurare
API_KEY=""
CITY_ID=""  # Puoi ottenere l'ID città da OpenWeatherMap
BOT_TOKEN=""
CHAT_ID=""
OWM_URL="http://api.openweathermap.org/data/2.5/weather"

# Funzione per inviare un messaggio a Telegram
send_to_telegram() {
  local message=$1
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
       -d chat_id="$CHAT_ID" \
       -d text="$message" \
       -d parse_mode="HTML"
}

# Ottieni i dati meteo da OpenWeatherMap
weather_data=$(curl -s "$OWM_URL?id=$CITY_ID&appid=$API_KEY&units=metric")

# Estrai temperatura, umidità e pressione dai dati JSON
temperature=$(echo $weather_data | jq '.main.temp')
humidity=$(echo $weather_data | jq '.main.humidity')
pressure=$(echo $weather_data | jq '.main.pressure')

# Componi il messaggio da inviare
message="🌤 Meteo aggiornato:"
message+="🌡️ Temperatura: ${temperature}°C; "
message+="💧 Umidità: ${humidity}%; "
message+="🌪️ Pressione: ${pressure} hPa"

# Invia il messaggio al canale Telegram
send_to_telegram "$message"
