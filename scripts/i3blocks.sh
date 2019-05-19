#!/bin/bash

# required for cpu temperature
sudo dnf install lm_sensors
# make dependencies
sudo dnf install autoconf automake
# font awesome support
sudo dnf install -y fontawesome-fonts

cd /tmp

git clone https://github.com/vivien/i3blocks
cd i3blocks

./autogen.sh
./configure

make
sudo make install
