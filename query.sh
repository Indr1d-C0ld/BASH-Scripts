#!/bin/bash

# Percorso al database SQLite
DB_PATH="/home/pi/data.db"

# Percorsi ai file referenza per HEX e Callsign militari
HEX_PREFIX_FILE="hex_prefixes.txt"
CALLSIGN_PATTERN_FILE="callsign_patterns.txt"

# Funzioni di ricerca
search_by_hex() {
    echo "Inserisci il codice HEX da cercare:"
    read hex_input
    [[ -z "$hex_input" ]] && { echo "Errore: non hai inserito un codice HEX."; return; }
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE hex LIKE '$hex_input%' ORDER BY last_updated ASC;" | less
}

search_by_callsign() {
    echo "Inserisci il callsign da cercare:"
    read callsign_input
    [[ -z "$callsign_input" ]] && { echo "Errore: non hai inserito un callsign."; return; }
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE callsign LIKE '$callsign_input%' ORDER BY last_updated ASC;" | less
}

filter_by_date() {
    echo "Inserisci la data (formato YYYY-MM-DD):"
    read date_input
    [[ -z "$date_input" ]] && { echo "Errore: non hai inserito una data valida."; return; }
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE last_updated LIKE '$date_input%' ORDER BY last_updated ASC;" | less
}

top_10_callsigns() {
    sqlite3 -header -column $DB_PATH "SELECT callsign, COUNT(*) AS count FROM flights WHERE callsign IS NOT NULL AND callsign != '' GROUP BY callsign ORDER BY count DESC LIMIT 10;" | less
}

top_10_hex() {
    sqlite3 -header -column $DB_PATH "SELECT hex, COUNT(*) AS count FROM flights WHERE hex NOT LIKE '~%' GROUP BY hex ORDER BY count DESC LIMIT 10;" | less
}

highest_altitude() {
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE altitude > 0 AND altitude != 'ground' AND hex NOT LIKE '~%' ORDER BY altitude DESC, last_updated ASC LIMIT 3;" | less
}

highest_speed() {
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE hex NOT LIKE '~%' ORDER BY speed DESC LIMIT 3;" | less
}

ground_flights() {
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE altitude = 'ground' AND hex NOT LIKE '~%' ORDER BY last_updated ASC;" | less
}

emergency_squawk() {
    sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE squawk IN ('7500', '7600', '7700');" | less
}

find_military_flights() {
    hex_query=$(awk '{print "hex LIKE \x27"$1"%\x27 OR "}' $HEX_PREFIX_FILE | sed '$ s/ OR $//')
    callsign_query=$(awk '{print "callsign LIKE \x27"$1"%\x27 OR "}' $CALLSIGN_PATTERN_FILE | sed '$ s/ OR $//')

    echo "============================="
    echo "  Ordinamento Voli Militari"
    echo "============================="
    echo "1. Ordina per Data (dal più vecchio)"
    echo "2. Ordina per HEX (alfabetico)"
    echo "3. Ordina per Callsign (alfabetico)"
    echo "============================="
    read -p "Scegli un'opzione: " order_choice

    case $order_choice in
        1) 
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE ($hex_query) OR ($callsign_query) ORDER BY last_updated ASC;" | less
            ;;
        2)
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE ($hex_query) OR ($callsign_query) ORDER BY hex ASC;" | less
            ;;
        3)
            sqlite3 -header -column $DB_PATH "SELECT * FROM flights WHERE ($hex_query) OR ($callsign_query) ORDER BY callsign ASC;" | less
            ;;
        *)
            echo "Opzione non valida."
            ;;
    esac
}

# Sottomenu per ricerca specifica
show_search_menu() {
    while true; do
        echo "============================="
        echo "      Ricerca Specifica"
        echo "============================="
        echo "1. Cerca per HEX"
        echo "2. Cerca per Callsign"
        echo "3. Torna al menu principale"
        echo "============================="
        read -p "Scegli un'opzione: " search_choice

        case $search_choice in
            1) search_by_hex ;;
            2) search_by_callsign ;;
            3) break ;;
            *) echo "Opzione non valida. Riprova." ;;
        esac
        echo "Premi INVIO per continuare..."
        read
    done
}

# Sottomenu per record e classifiche
show_records_menu() {
    while true; do
        echo "============================="
        echo "      Record e Classifiche"
        echo "============================="
        echo "1. Classifica dei 10 Callsign più frequenti"
        echo "2. Classifica dei 10 HEX più frequenti"
        echo "3. Top 3 voli con altezza massima"
        echo "4. Top 3 voli con velocità massima"
        echo "5. Torna al menu principale"
        echo "============================="
        read -p "Scegli un'opzione: " records_choice

        case $records_choice in
            1) top_10_callsigns ;;
            2) top_10_hex ;;
            3) highest_altitude ;;
            4) highest_speed ;;
            5) break ;;
            *) echo "Opzione non valida. Riprova." ;;
        esac
        echo "Premi INVIO per continuare..."
        read
    done
}

# Menu principale
show_menu() {
    echo "============================="
    echo "   Interrogazioni Database"
    echo "============================="
    echo "1. Ricerca Specifica (HEX o Callsign)"
    echo "2. Filtra per Data"
    echo "3. Mostra Record e Classifiche"
    echo "4. Mostra voli con Squawk di Emergenza"
    echo "5. Isola voli militari"
    echo "6. Mostra voli Ground (altezza = 'ground')"
    echo "7. Esci"
    echo "============================="
}

# Ciclo principale
while true; do
    show_menu
    read -p "Scegli un'opzione: " choice
    case $choice in
        1) show_search_menu ;;
        2) filter_by_date ;;
        3) show_records_menu ;;
        4) emergency_squawk ;;
        5) find_military_flights ;;
        6) ground_flights ;;
        7) echo "Uscita dal programma. A presto!"; exit ;;
        *) echo "Opzione non valida. Riprova." ;;
    esac
    echo "Premi INVIO per continuare..."
    read
done

