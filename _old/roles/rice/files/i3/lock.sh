#!/bin/bash

IMG=/tmp/screen.png

scrot $IMG

convert $IMG -blur 0x5 $IMG

#feh $IMG

i3lock -i $IMG
rm $IMG