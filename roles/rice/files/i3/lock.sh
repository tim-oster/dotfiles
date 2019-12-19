#!/bin/bash

IMG=/tmp/screen.png
maim $IMG
convert $IMG -blur 0x5 $IMG

i3lock -i $IMG
rm $IMG
