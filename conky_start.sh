#!/bin/bash

sleep 10

conky -c /home/randolph/.config/conky/serverpi.conf &

conky -c /home/randolph/.config/conky/adsb.conf &
