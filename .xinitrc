#!/bin/sh
xmodmap /home/steffoz/.xmodmaprc
pidgin &
checkgmail &
sonata &
exec awesome
