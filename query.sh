#!/bin/bash

DB_PATH="/home/pi/data.db"  # Percorso al database SQLite

# Liste dei prefissi HEX e Callsign militari
# hex_prefixes=("AE" "43" "33" "3E" "3F" "4A" "3A" "45" "C0" "7C" "48" "44" "4D" "14" "15" "70" "71")
# callsign_patterns=("IAM" "FAF" "ASCOT" "RCH" "GAF" "CANFORCE" "AME" "ASY" "NAF" "PLF" "NATO" "MAGIC")
hex_prefixes=($(<hex_prefixes.txt))
callsign_patterns=($(<callsign_patterns.txt))

# Funzione per costruire query SQL per prefissi HEX
build_hex_query() {
    local condition=""
    for prefix in "${hex_prefixes[@]}"; do
        condition+="hex LIKE '$prefix%' OR "
    done
    condition="${condition% OR }"  # Rimuove l'ultimo 'OR'
    echo "$condition"
}

# Funzione per costruire query SQL per Callsign
build_callsign_query() {
    local condition=""
    for pattern in "${callsign_patterns[@]}"; do
        condition+="callsign LIKE '%$pattern%' OR "
    done
    condition="${condition% OR }"  # Rimuove l'ultimo 'OR'
    echo "$condition"
}

# Funzione per ricerca interattiva di HEX
search_by_hex() {
    echo "Inserisci il codice HEX da cercare:"
    read hex_input
    if [[ -z "$hex_input" ]]; then
        echo "Errore: non hai inserito un codice HEX."
        return
    fi
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE hex LIKE '%$hex_input%';"
}

# Funzione per ricerca interattiva di Callsign
search_by_callsign() {
    echo "Inserisci il callsign da cercare:"
    read callsign_input
    if [[ -z "$callsign_input" ]]; then
        echo "Errore: non hai inserito un callsign."
        return
    fi
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE callsign LIKE '%$callsign_input%';"
}

# Funzione per trovare voli militari
find_military_flights() {
    echo "============================="
    echo "   Opzioni per voli militari"
    echo "============================="
    echo "1. Cerca per prefisso HEX"
    echo "2. Cerca per Callsign"
    echo "3. Cerca entrambi (HEX + Callsign)"
    echo "4. Torna al menu principale"
    read -p "Scegli un'opzione: " military_choice

    case $military_choice in
        1)
            query=$(build_hex_query)
            echo "Eseguo la ricerca per prefissi HEX militari..."
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE $query;"
            ;;
        2)
            query=$(build_callsign_query)
            echo "Eseguo la ricerca per callsign militari..."
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE $query;"
            ;;
        3)
            hex_query=$(build_hex_query)
            callsign_query=$(build_callsign_query)
            echo "Eseguo la ricerca combinata per HEX e Callsign militari..."
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE ($hex_query) OR ($callsign_query);"
            ;;
        4)
            return ;;
        *)
            echo "Opzione non valida. Riprova." ;;
    esac
}

# Funzioni per statistiche e query
filter_by_date() {
    echo "Inserisci la data (formato YYYY-MM-DD):"
    read date_input
    if [[ -z "$date_input" ]]; then
        echo "Errore: non hai inserito una data valida."
        return
    fi
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE last_updated LIKE '$date_input%';"
}

top_10_callsigns() {
    sqlite3 -header -column $DB_PATH "SELECT callsign, COUNT(*) AS count FROM flights GROUP BY callsign ORDER BY count DESC LIMIT 10;"
}

top_10_hex() {
    sqlite3 -header -column $DB_PATH "SELECT hex, COUNT(*) AS count FROM flights GROUP BY hex ORDER BY count DESC LIMIT 10;"
}

average_altitude() {
    sqlite3 -header -column $DB_PATH "SELECT AVG(altitude) AS avg_altitude FROM flights WHERE altitude IS NOT NULL;"
}

average_speed() {
    sqlite3 -header -column $DB_PATH "SELECT AVG(speed) AS avg_speed FROM flights WHERE speed IS NOT NULL;"
}

emergency_squawk() {
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE squawk IN ('7500', '7600', '7700');"
}

# Menu principale
show_menu() {
    echo "============================="
    echo "   Interrogazioni Database"
    echo "============================="
    echo "1. Cerca per HEX"
    echo "2. Cerca per Callsign"
    echo "3. Filtra per Data"
    echo "4. Classifica dei 10 Callsign più frequenti"
    echo "5. Classifica dei 10 HEX più frequenti"
    echo "6. Altitudine Media dei voli"
    echo "7. Velocità Media dei voli"
    echo "8. Mostra voli con Squawk di Emergenza"
    echo "9. Isola voli militari"
    echo "10. Esci"
    echo "============================="
}

# Ciclo principale
while true; do
    show_menu
    read -p "Scegli un'opzione: " choice
    case $choice in
        1) search_by_hex ;;
        2) search_by_callsign ;;
        3) filter_by_date ;;
        4) top_10_callsigns ;;
        5) top_10_hex ;;
        6) average_altitude ;;
        7) average_speed ;;
        8) emergency_squawk ;;
        9) find_military_flights ;;
        10) echo "Uscita dal programma. A presto!"; exit ;;
        *) echo "Opzione non valida. Riprova." ;;
    esac
    echo "Premi INVIO per continuare..."
    read
done

