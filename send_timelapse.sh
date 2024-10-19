#!/bin/bash

# Configurazione
TOKEN="MY BOT TOKEN"
CHANNEL_ID="CHANNEL ID"

# Data di oggi in formato AAAAMMDD
DATA=$(date +%Y%m%d)

# Cartella contenente i file
CARTELLA="/home/pi/allsky/images/$DATA"

# Controlla se la cartella esiste
if [ ! -d "$CARTELLA" ]; then
    echo "La cartella $CARTELLA non esiste."
    exit 1
fi

# Invia i file nella cartella
for FILE in "$CARTELLA"/*.mp4; do
    if [ -f "$FILE" ]; then
        # Invia il file
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendVideo" -F "chat_id=$CHANNEL_ID" -F "video=@$FILE"
        echo "Inviato $FILE"
    fi
done
