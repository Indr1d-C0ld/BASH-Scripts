#!/bin/bash

DB_PATH="/home/pi/data.db"  # Percorso al database SQLite

# Funzione per mostrare il menu principale
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
    echo "0. Esci"
    echo "============================="
}

# Funzione per cercare per HEX
search_by_hex() {
    read -p "Inserisci l'HEX del volo: " hex
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE hex = '$hex';"
}

# Funzione per cercare per Callsign
search_by_callsign() {
    read -p "Inserisci il Callsign del volo: " callsign
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE callsign LIKE '%$callsign%';"
}

# Funzione per filtrare per data
filter_by_date() {
    read -p "Inserisci la data (formato YYYY-MM-DD): " date
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE DATE(last_updated) = '$date';"
}

# Funzione per mostrare la classifica dei 10 callsign più frequenti
top_10_callsigns() {
    sqlite3 -header -column $DB_PATH "SELECT callsign, COUNT(*) AS Frequenza FROM flights GROUP BY callsign ORDER BY Frequenza DESC LIMIT 10;"
}

# Funzione per mostrare la classifica dei 10 HEX più frequenti
top_10_hex() {
    sqlite3 -header -column $DB_PATH "SELECT hex, COUNT(*) AS Frequenza FROM flights GROUP BY hex ORDER BY Frequenza DESC LIMIT 10;"
}

# Funzione per calcolare l'altitudine media
average_altitude() {
    sqlite3 -header -column $DB_PATH "SELECT AVG(altitude) AS AltitudineMedia FROM flights WHERE altitude IS NOT NULL;"
}

# Funzione per calcolare la velocità media
average_speed() {
    sqlite3 -header -column $DB_PATH "SELECT AVG(speed) AS VelocitaMedia FROM flights WHERE speed IS NOT NULL;"
}

# Funzione per mostrare voli con squawk di emergenza
emergency_squawk() {
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE squawk IN ('7500', '7600', '7700');"
}

# Funzione per isolare i voli militari
find_military_flights() {
    echo "============================="
    echo "   Opzioni per voli militari"
    echo "============================="
    echo "1. Cerca per prefisso HEX"
    echo "2. Cerca per Callsign"
    echo "3. Torna al menu principale"
    read -p "Scegli un'opzione: " military_choice

    case $military_choice in
        1)
            echo "Inserisci i prefissi HEX separati da uno spazio (es. AE 4A 33):"
            read -a hex_prefixes
            condition=""
            for prefix in "${hex_prefixes[@]}"; do
                condition+="hex LIKE '$prefix%' OR "
            done
            condition="${condition% OR }" # Rimuove l'ultimo 'OR'
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE $condition;"
            ;;
        2)
            echo "Inserisci i callsign noti (es. IAM BLUE) separati da uno spazio:"
            read -a callsign_patterns
            condition=""
            for callsign in "${callsign_patterns[@]}"; do
                condition+="callsign LIKE '%$callsign%' OR "
            done
            condition="${condition% OR }" # Rimuove l'ultimo 'OR'
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE $condition;"
            ;;
        3) return ;;
        *) echo "Opzione non valida. Riprova." ;;
    esac
}

# Ciclo principale del menu
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
        0) echo "Uscita dal programma. A presto!"; exit ;;
        *) echo "Opzione non valida. Riprova." ;;
    esac
    echo "Premi INVIO per continuare..."
    read
done

