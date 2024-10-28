#!/bin/bash

# Configura il percorso del file JSON generato da tar1090
JSON_FILE="/var/run/adsbfi-feed/aircraft.json"  # Percorso al file JSON dei dati di volo
# JSON_FILE="/home/randolph/test.json"

# Configura il TOKEN e il CHAT_ID del canale Telegram
TOKEN="7984714705:AAEAKO_LzvFDa4OUcUXgmMjtJiisap_3HO4"
CHAT_ID="-1002270663940"

# Funzione per inviare il messaggio a Telegram
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d parse_mode="Markdown"
}

# Controlla periodicamente i codici squawk di emergenza
while true; do
    # Estrai gli aerei con codice squawk di emergenza dal JSON
    emergency_flights=$(jq -c '.aircraft[] | select(.squawk == "7500" or .squawk == "7600" or .squawk == "7700")' "$JSON_FILE")

    # Verifica se sono presenti voli di emergenza
    if [[ -n "$emergency_flights" ]]; then
        # Loop sui voli di emergenza trovati
        echo "$emergency_flights" | while read -r flight; do
            # Estrai informazioni del volo
            hex_id=$(echo "$flight" | jq -r '.hex')
            flight_id=$(echo "$flight" | jq -r '.flight')
            squawk_code=$(echo "$flight" | jq -r '.squawk')
            altitude=$(echo "$flight" | jq -r '.alt_baro // "N/A"')
            speed=$(echo "$flight" | jq -r '.gs // "N/A"')
            latitude=$(echo "$flight" | jq -r '.lat // "N/A"')
            longitude=$(echo -e "$flight" | jq -r '.lon // "N/A"')

            # Prepara il messaggio
            message="✈️ 🆘  *** Emergency Squawk Detected! *** *>>* *Hex:* #$hex_id; *Flight:* #$flight_id; *Squawk:* $squawk_code; *Alt.:* $altitude ft; *Speed:* $speed kn; *Position:* https://www.google.com/maps/@$latitude,$longitude,10z"

            # Invia il messaggio a Telegram
            send_telegram_message "$message"
        done
    fi

    # Attende 60 secondi prima di verificare nuovamente
    sleep 60
done

