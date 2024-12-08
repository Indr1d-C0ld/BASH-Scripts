#!/bin/bash

# Colori per migliorare la leggibilità
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Nessun colore

# Menu principale
while true; do
    clear
    echo -e "${GREEN}Wi-Fi Manager${NC}"
    echo "1. Elenca reti disponibili"
    echo "2. Connetti a una rete"
    echo "3. Mostra connessione attuale"
    echo "4. Elimina una configurazione salvata"
    echo "5. Esci"
    echo -n "Seleziona un'opzione: "
    read -r scelta

    case $scelta in
        1) # Elenca reti disponibili
            echo -e "\n${YELLOW}Reti disponibili:${NC}"
            nmcli device wifi list
            read -rp "Premi Invio per continuare..."
            ;;
        2) # Connetti a una rete
            echo -n "Inserisci il nome della rete (SSID): "
            read -r ssid
            echo -n "Inserisci la password (lascia vuoto se aperta): "
            read -rs password
            echo
            if [ -z "$password" ]; then
                nmcli device wifi connect "$ssid"
            else
                nmcli device wifi connect "$ssid" password "$password"
            fi

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Connesso con successo a $ssid.${NC}"
            else
                echo -e "${RED}Errore durante la connessione a $ssid.${NC}"
            fi
            read -rp "Premi Invio per continuare..."
            ;;
        3) # Mostra connessione attuale
            echo -e "\n${YELLOW}Connessione attuale:${NC}"
            nmcli connection show --active
            read -rp "Premi Invio per continuare..."
            ;;
        4) # Elimina una configurazione salvata
            echo -e "\n${YELLOW}Configurazioni salvate:${NC}"
            nmcli connection show
            echo -n "Inserisci il nome della connessione da eliminare: "
            read -r conn_name
            nmcli connection delete "$conn_name"

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Configurazione $conn_name eliminata.${NC}"
            else
                echo -e "${RED}Errore durante l'eliminazione di $conn_name.${NC}"
            fi
            read -rp "Premi Invio per continuare..."
            ;;
        5) # Esci
            echo -e "${GREEN}Uscita dal Wi-Fi Manager. A presto!${NC}"
            exit 0
            ;;
        *) # Opzione non valida
            echo -e "${RED}Opzione non valida!${NC}"
            sleep 1
            ;;
    esac
done

