#!/bin/bash

# first:
# sudo apt install libcamera-apps vlc -y
# open "network stream" in vlc and insert in URL:
# rtsp://192.168.1.8:5555/ (your IP address)
# in advanced options add ":demux=h264"

rpicam-vid -t 0 --width 1296 --height 972 --framerate 60 --hflip 1 --vflip 1 --inline -o - | cvlc stream:///dev/stdin --sout '#rtp{sdp=rtsp://:5555/}' :demux=h264
