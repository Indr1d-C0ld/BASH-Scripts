#!/bin/bash

BOT_TOKEN=""
CHAT_ID=""

# Path del file JSON di dump1090
JSON_FILE="/var/run/readsb/aircraft.json"

# Ottieni il volo militare più vicino
NEAREST_MIL_FLIGHT=$(jq -r '.aircraft[] | select(.flight and (.flight | test("^(AME|UAF).*"))) | "\(.flight) \(.lat) \(.lon) Alt: \(.alt_baro)"' $JSON_FILE | head -n 1)

# Se non ci sono voli militari
if [ -z "$NEAREST_MIL_FLIGHT" ]; then
    exit 1
fi

# Messaggio del volo militare
MESSAGE="Volo militare più vicino: $NEAREST_MIL_FLIGHT"

# Invia il messaggio al canale Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$MESSAGE"
