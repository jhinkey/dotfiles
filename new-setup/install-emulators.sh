#!/bin/sh

# Emulators 

sudo pacman -S --noconfirm vice dosemu dosbox

yay -S --noconfirm fs-uae-devel fs-uae-launcher-devel aranym atari800 linapple hfsutils yaze 
yay -S --noconfirm basiliskii-git         
mkdir ~/.config/linapple
cp /usr/share/linapple/config/* ~/.config/linapple
