#!/bin/bash

sudo dnf install lm_sensors
sudo dnf install autoconf automake

cd /tmp

git clone https://github.com/vivien/i3blocks
cd i3blocks

./autogen.sh
./configure

make
sudo make install
