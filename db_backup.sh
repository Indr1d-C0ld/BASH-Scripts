#!/bin/bash

# Compressione: Se vuoi salvare spazio, puoi aggiungere una compressione al file di backup:
# gzip -c "$SOURCE" > "$BACKUP.gz"

# Rotazione dei Backup: Per mantenere più versioni dei backup, puoi aggiungere la data al nome del file di backup:
# cp "$SOURCE" "/home/pi/data_$(date '+%Y%m%d').db_backup"

# E poi pianificare un processo di pulizia con CRON per rimuovere i backup più vecchi di un certo numero di giorni:
# find /home/pi/ -name "data_*.db_backup" -mtime +30 -exec rm {} \;

# Percorsi dei file
SOURCE="/home/pi/data.db"
BACKUP="/home/pi/data.db_backup"

# Controlla se il file sorgente esiste
if [[ -f "$SOURCE" ]]; then
    # Copia il file sorgente nel file di backup
    cp "$SOURCE" "$BACKUP"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup completato con successo." >> /home/pi/backup.log
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - File sorgente non trovato, backup fallito." >> /home/pi/backup.log
fi

