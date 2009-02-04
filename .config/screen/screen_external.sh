#!/bin/bash
cp -f /home/steffoz/.config/screen/xorg.conf.external /etc/xorg.conf
aticonfig --input /etc/xorg.conf --enable-monitor=crt2 --desktop-setup=single --resolution=0,1680x1050 --hsync=0,30-93 --vrefresh=0,56-76 --nobackup
