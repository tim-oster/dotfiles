#!/bin/bash

sudo dnf install i3 i3status i3lock dmenu
sudo dnf install fontawesome-fonts
sudo dnf install network-manager-applet
# setup i3blocks

sudo dnf install nano
sudo dnf install arandr

sudo dnf install ImageMagick scrot

# google chrome
sudo dnf install fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome
sudo dnf install google-chrome

# golang
sudo dnf install golang
mkdir ~/go

# terminator
sudo dnf install python-requests
sudo dnf install terminator

# stuff
sudo dnf install rofi feh
sudo dnf install redshift

# zsh
sudo dnf install zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# copy wallpaper
# copy .zshrc
# copy .config directory

# cleanup directories
rmdir ~/Desktop ~/Documents ~/Music ~/Public ~/Templates ~/Videos ~/Picutres

# 3rd party programs
bash flat_install.sh discord
bash flat_install.sh spotify
bash flat_install.sh telegram
bash flat_install.sh teamspeak
bash flat_install.sh slack

xrdb ~/.Xresources
