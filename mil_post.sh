#!/bin/bash

BOT_TOKEN="7034351346:AAGp0J0rniIQWyrLjOVIhfCf-3YSiMLpd5s"
CHAT_ID="-1002270663940"

# Path del file JSON di dump1090
JSON_FILE="/var/run/adsbfi-feed/aircraft.json"
# JSON_FILE="/home/randolph/test.json"

# Ottieni il volo militare più vicino
NEAREST_MIL_FLIGHT=$(jq -r '.aircraft[] | select(.flight and (.flight | test("^(AME|ASY|BAF|BAH|BLUE|CEF|CFC|CMB|CTM|CNV|CPI|FAF|FLTCK|FMY|FNY|GAF|HAF|HUAF|IAF|IAM|KAF|LHOB|NAF|NATO|PAAF|PAT|PANTE|PLF|QID|RCH|RFF|ROF|RRF|RRR|RSF|SPHYR|SUI|TUAF|UAF).*"))) | "Hex: #\(.hex); Flight: #\(.flight); Squawk: \(.squawk); Alt.: \(.alt_baro)ft; Position: https://www.google.com/maps/@\(.lat),\(.lon),10z"' $JSON_FILE | head -n 1)

# Se non ci sono voli militari
if [ -z "$NEAREST_MIL_FLIGHT" ]; then
    exit 1
fi

# Messaggio del volo militare
MESSAGE="Volo militare più vicino: $NEAREST_MIL_FLIGHT"

# Invia il messaggio al canale Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$MESSAGE"
