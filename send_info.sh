#!/bin/bash

# Configura qui il token del bot e il chat ID del canale
TOKEN=""
CHAT_ID=""

# Raccolta dati diagnostici
TEMP_CPU=$(vcgencmd measure_temp | cut -d '=' -f 2)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
RAM_USAGE=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
DISK_USAGE=$(df -h | awk '$NF=="/"{print $3 "/" $2}')
UPTIME=$(uptime -p)

# Crea il messaggio da inviare
MESSAGE="🌡 *Raspberry Pi Diagnostics*:
- 🖥 *Temperatura CPU*: $TEMP_CPU
- 💽 *Utilizzo CPU*: $CPU_USAGE
- 🧠 *Utilizzo RAM*: $RAM_USAGE
- 🗄 *Spazio su disco*: $DISK_USAGE
- ⏲ *Uptime*: $UPTIME"

# Invia il messaggio su Telegram
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
  -d chat_id=$CHAT_ID \
  -d parse_mode="Markdown" \
  -d text="$MESSAGE"
