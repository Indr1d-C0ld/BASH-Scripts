#!/bin/bash

cd /root/backup/mystic
tar -zcvf "$(date '+%d%m%y').tar.gz" /mystic/
