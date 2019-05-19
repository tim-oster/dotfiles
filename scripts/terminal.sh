#!/bin/bash

sudo dnf install -y terminator
rm -rf ~/.config/terminator
cp -R files/.config/terminator ~/.config

sudo dnf install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
