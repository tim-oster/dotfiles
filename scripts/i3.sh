#!/bin/bash

# i3 packages
sudo dnf install -y i3 i3status i3lock
# utils for blur lock screen
sudo dnf install -y ImageMagick scrot
# dmenu alternative
sudo dnf install -y rofi
# background image
sudo dnf install -y feh

rm -rf ~/.config/i3
cp -R files/.config/i3 ~/.config
