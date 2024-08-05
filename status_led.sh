#!/usr/bin/python
import RPi.GPIO as GPIO
import os
import subprocess
import time
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(17, GPIO.OUT)#Sets the GPIO pin to be an output pin
GPIO.setup(27, GPIO.OUT)
GPIO.output(17, False) #Makes sure all LED's are at the same state (off)
GPIO.output(27, False)

while True:
	MPD_FILE = b"/usr/bin/mpd"
	REDIS_FILE = b"/usr/bin/redis-server"
	
	output = subprocess.check_output(["ps", "-ef"])

	if MPD_FILE in output:
		GPIO.output(17, True) #Turn on GREEN LED
	else:
		GPIO.output(17, False) #Turn off GREEN LED

	if REDIS_FILE in output:
		GPIO.output(27, True) #Turn on RED LED
	else:
		GPIO.output(27, False) #Turn off RED LED
	time.sleep(10)  # Delay for 10 seconds
