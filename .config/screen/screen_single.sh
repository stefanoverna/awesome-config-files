#!/bin/bash
cp -f /home/steffoz/.config/screen/xorg.conf.single  /etc/xorg.conf
aticonfig --input /etc/xorg.conf --enable-monitor=lvds --desktop-setup=single --resolution=0,1400x900 --nobackup
