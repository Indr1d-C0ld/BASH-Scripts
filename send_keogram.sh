#!/bin/bash

# Configurazione
TOKEN="MY BOT TOKEN"
CHANNEL_ID="CHANNEL ID"

# Ottieni la data di ieri in formato AAAAMMDD
DATA=$(date -d "yesterday" +"%Y%m%d")

# Cartella contenente i file
CARTELLA="/home/pi/allsky/images/$DATA/keogram"

# Controlla se la cartella esiste
if [ ! -d "$CARTELLA" ]; then
    echo "La cartella $CARTELLA non esiste."
    exit 1
fi

# Invia i file nella cartella
for FILE in "$CARTELLA"/*; do
    if [ -f "$FILE" ]; then
        # Invia il file
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$CHANNEL_ID" -F "photo=@$FILE"
        echo "Inviato $FILE"
    fi
done
