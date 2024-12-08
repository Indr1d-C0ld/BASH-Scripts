#!/bin/bash

# Indirizzo IP del sistema remoto
REMOTE_IP="192.168.178.59"

# Percorso al file di configurazione di Conky
CONKY_CONFIG="/home/randolph/.config/conky/hp_mini.conf"

# Nome univoco per identificare l'istanza di Conky associata
UNIQUE_ID="hp_mini"

echo "Monitoraggio della connessione al sistema remoto ($REMOTE_IP)..."

while true; do
    # Verifica se il sistema remoto è raggiungibile
    if ping -c 1 -W 1 "$REMOTE_IP" &> /dev/null; then
        # Controlla se questa specifica istanza di Conky è già in esecuzione
        if ! pgrep -f "conky.*$CONKY_CONFIG" > /dev/null; then
            echo "Il sistema remoto è online. Avvio Conky con il file di configurazione $CONKY_CONFIG..."
            conky -c "$CONKY_CONFIG" --daemonize --pause=1 &
        else
            echo "Conky per $CONKY_CONFIG è già in esecuzione."
        fi
    else
        # Chiudi solo l'istanza di Conky associata a questo file di configurazione
        if pgrep -f "conky.*$CONKY_CONFIG" > /dev/null; then
            echo "Il sistema remoto è offline. Chiudo Conky associato a $CONKY_CONFIG..."
            pkill -f "conky.*$CONKY_CONFIG"
        else
            echo "Conky per $CONKY_CONFIG non è in esecuzione."
        fi
    fi

    # Attendi 5 secondi prima di controllare di nuovo
    sleep 10
done
