#!/bin/bash
cp -f /home/steffoz/.config/screen/xorg.conf.clone /etc/xorg.conf
aticonfig --input /etc/xorg.conf --desktop-setup=clone --resolution=0,1400x900 --hsync2=30-93 --vrefresh2=56-76 --mode2=1680x1050 --nobackup
