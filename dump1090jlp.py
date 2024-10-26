# -*- coding: utf-8 -*-
import json
import time
import datetime
import fnmatch
import subprocess

# -----------------------Задаем параметры---------------------

# Файл dump1090 aircraft.json
json_aircrafts = '/var/run/adsbfi-feed/aircraft.json'

# Выборка необходимых позывных
mask_callsign = {
                'ADB*':'Antonov Airlines Flight',
                'AME*':'Spanish Air Force Flight',
                'ASY*':'Royal Australian Air Force Flight',
		'AUH*':'United Arab Emirates Government Flight',
                'BAF*':'Belgian Air Component Flight',
		'BAH*':'Bahrain Defence Force Flight',
		'BLUE*':'US Air Force Flight',
                'CEF*':'Czech Air Force Flight',
                'CFC*':'Royal Canadian Air Force Flight',
		'CMB*':'US Transportation Command Flight',
		'CTM*':'French Air Force Flight',
                'CNV*':'US Navy Flight',
		'CPI*':'Compagnia Aeronautica Italiana Flight',
		'DSO*':'Dassault Aviation Flight',
		'DRAG*':'Italian Fire Fighters Flight',
		'DUB*':'United Arab Emirates Government Flight',
		'EGY01':'Egyptian Government Flight',
		'ENF*':'ENAV Flight',
                'FAF*':'French Air Force Flight',
                'FMY*':'French Army Flight',
                'FNY*':'French Navy Flight',
                'GAF*':'German Air Force Flight',
		'GCI*':'Italian Coast Guard',
                'HAF*':'Greek Air Force Flight',
		'GRIFO*':'Guardia di Finanza Flight',
                'HUAF*':'Hungarian Air Force Flight',
                'IAF*':'Israeli Air Force Flight',
                'IAM*':'Italian Air Force Flight',
		'IDPC*':'Italian Fire Fighters Flight',
		'KAF*':'Kuwait Air Force Flight',
		'LHOB*':'Qatar Emiri Air Force Flight',
		'MEDVC*':'Air Ambulance Flight',
		'MILAN*':'French Securite Civile Flight',
                'NAF*':'Royal Netherlands Air Force Flight',
		'NATO*':'NATO Flight',
		'PAAF*':'Pakistan Air Force Flight',
                'PAT*':'US Army Flight',
		'PANTE*':'Maybe Tornado Flight from Ghedi AB',
		'PEGAS*':'PEGASO Italian Air Ambulance Flight',
		'PHGOV':'Netherlands Government Flight',
		'POF*':'French Police Flight',
		'POLI*':'Italian Police Flight',
                'PLF*':'Polish Air Force Flight',
                'QID*':'US Air Force Flight',
                'RCH*':'US Air Force Flight',
                'RFF*':'Russian Air Force Flight',
                'ROF*':'Romanian Air Force Flight',
                'RRF*':'Royal Air Force Flight',
                'RRR*':'Royal Air Force Flight',
                'RSF*':'Royal Saudi Air Force Flight',
                'SPHYR*':'Pakistan Government Flight',
		'SUB*':'Egyptian Government Flight',
                'SUI*':'Swiss Air Force Flight',
                'UAF*':'United Arab Emirates Air Force Flight',
                'UNO*':'United Nations Flight',
		'VOLPE*':'Guardia di Finanza Flight'
                }

# Выборка необходимых HEX
mask_hex = {
		'ad*':'US Air Force Flight',
		'ae*':'US Air Force Flight',
		'af*':'US Air Force Flight',
		'018019':'Libyan Government Flight',
		'02b26a':'Tunisian Air Force Flight',
		'0a401c':'Algerian Air Force Flight',
		'04200a':'Equatorial Guinea Air Corps Flight',
		'06a001':'Qatar Emiri Air Force Flight',
		'064002':'Nigerian Air Force Flight',
		'090088':'Government of Angola Flight',
		'3b75*':'French Air Force Flight',
		'3b76*':'French Air Force Flight',
		'3b77*':'French Air Force Flight',
		'3ce02b':'German Aerospace Center Flight',
		'3004b8':'Compagnia Generale Riprese Aeree Flight',
		'300789':'Compagnia Generale Riprese Aeree Flight',
		'33f*':'Italian Air Force Flight',
		'39b415':'French Government Flight',
		'4b85c1':'Albania Government Flight',
		'4c0639':'Government of Serbia Flight',
		'4d403f':'Government of Monaco Flight',
		'505c09':'Slovak Government Flight',
		'516001':'Montenegrin Air Force Flight'
	   }

# Через сколько времени считать появление борта новым (секунды)
ttl_max = 3600

# Путь к скрипту, который будет запущен при совпадении масок
# script = '/home/randolph/alert.sh'
script = 'telegram-send "*** Flight Alert! ***"'

# Период сканирования (time to scan)
tts = 30

msg = "ADSB Radar Roselle (GR)"

# -----------------------------------------------------------

# Watched flights
flights_hex = {}
flights_callsign = {}


def check_ttl():
    global flights_hex
    global flights_callsign
    cp_flights_hex = flights_hex.copy()
    cp_flights_callsign = flights_callsign.copy()
    for i in cp_flights_hex:
        ttl = time.time() - cp_flights_hex[i]
        if ttl > ttl_max:
            del flights_hex[i]
    for i in cp_flights_callsign:
        ttl = time.time() - cp_flights_callsign[i][0]
        if ttl > ttl_max:
            del flights_callsign[i]

def update_dict_hex(hex):
    if hex not in flights_hex:
        flights_hex[hex] = time.time()
        return True
    else:
        flights_hex[hex] = time.time()
        return False

def update_dict_callsign(hex, callsign):
    if hex not in flights_callsign:
        flights_callsign[hex] = [time.time(), callsign]
        return True
    else:
        if flights_callsign[hex][1] == callsign:
            flights_callsign[hex] = [time.time(), callsign]
            return False
        flights_callsign[hex] = [time.time(), callsign]
        return True

def is_valid_jet(hex, callsign):
    for mask in mask_hex:
        if fnmatch.fnmatch(hex, mask):
            if update_dict_hex(hex):
                today = datetime.datetime.today()
                cmd = '{0} "{1} @ {2}: {3} >> Hex: "#"{4}"'.format(script, today.strftime("[%H:%M] %d.%m.%Y"), msg, mask_hex[mask], hex)
                subprocess.call(cmd, shell=True)
    for mask in mask_callsign:
        if fnmatch.fnmatch(callsign, mask):
            if update_dict_callsign(hex, callsign):
                today = datetime.datetime.today()
                cmd = '{0} "{1} @ {2}: {3} >> Callsign: "#"{4} // Hex: "#"{5}"'.format(script, today.strftime("[%H:%M] %d.%m.%Y"), msg, mask_callsign[mask], callsign, hex)
                subprocess.call(cmd, shell=True)

if __name__ == '__main__':
    while True:
        try:
            with open(json_aircrafts) as json_file:
                data = json.load(json_file)
        except:
            pass
        else:            
            check_ttl()
            for x in data['aircraft']:
                if 'flight' in x.keys():
                    is_valid_jet(x['hex'].upper(), x['flight'].strip())
                else:
                    is_valid_jet(x['hex'].upper(), '')
        time.sleep(tts)
