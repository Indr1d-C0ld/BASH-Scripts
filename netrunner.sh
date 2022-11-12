#!/bin/bash

### Semplice script BASH per cambiare al volo il layout della 
### tastiera prima di eseguire un programma in WINE da console, 
### per poi ripristinare il layout precedente

# Accedi nella cartella di lavoro:
cd "/home/randolph/.wine/drive_c/Program Files/NetRunner/"

# Cambia keyboard layout in US per il programma da eseguire:
setxkbmap us

# Esegui il programma:
wine netrunner.exe

# Riporta keyboard layout in IT all'uscita dal programma:
trap "setxkbmap it" EXIT

