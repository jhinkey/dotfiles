#!/bin/sh

## Add this to /etc/pacman.conf first 

#[infinality-bundle] 
#Server = http://bohoomil.com/repo/$arch 

#[infinality-bundle-multilib] 
#Server = http://bohoomil.com/repo/multilib/$arch 

#[infinality-bundle-fonts] 
#Server = http://bohoomil.com/repo/fonts 

# Infinality Fonts

#sudo pacman-key -r 962DDE58
#sudo pacman-key --lsign-key 962DDE58

#cat /etc/pacman.conf infinality-repos.txt > font-repos.txt
#sudo cp font-repos.txt /etc/pacman.conf

sudo pacman-mirrors -f 0
sudo pacman -Syu

# Environment 

sudo pacman -S --noconfirm festival festival-english festival-us pacaur yaourt
function say { echo "$1" | festival --tts; }
export -f say
DIALOG=whiptail

## Editor 

sudo pacman -S --noconfirm neovim joe python-neovim

## Mouse Cursors

sudo pacman -U --noconfirm breeze-red-cursor-theme-1.0-3-any.pkg.tar.xz oxygen-cursors-extra-5.10.5-1-any.pkg.tar.xz
#yaourt -S --noconfirm breeze-red-cursor-theme

## Fonts

sudo pacman -S --noconfirm ttf-linux-libertine ttf-gentium 
yaourt -S --noconfirm otf-fantasque-sans-mono ttf-mplus otf-vegur otf-tenderness ttf-exljbris otf-hermit ttf-anonymice-powerline-git ttf-caladea ttf-carlito 

sudo cp fonts-local.conf /etc/fonts/local.conf
cp fonts.conf ~/.config/fontconfig
sudo mkdir /usr/share/fonts/TTF
sudo mkdir /usr/share/fonts/OTF
sudo cp fonts/*.ttf /usr/share/fonts/TTF
sudo cp fonts/*.otf /usr/share/fonts/OTF
sudo fc-cache -f -v

say "Do you want all the Google fonts?"

GoogleFonts=$($DIALOG --radiolist "Do you want all the Google Fonts?" 20 60 12 \
    "y" "Install Google Fonts"  on \
    "n" "Too big; skip it"      off 2>&1 >/dev/tty)

if echo "$GoogleFonts" | grep -iq "^y" ;then
    echo "Installing Google Fonts!"
    sudo pacman -R noto-fonts ttf-droid ttf-inconsolata
    yaourt -S ttf-google-fonts-git
else
    echo "Skipping Google Fonts install...."
fi

## Console config

say "Does this machine have a HIDPI screen?"
if $DIALOG --yesno "HIDPI screen?" 20 60 ;then
    sudo cp vconsole.conf /etc
else 
    echo "Nope." 
fi

# Syncthing

sudo pacman -S --noconfirm syncthing syncthing-gtk 
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.d/90-override.conf

# Grub

yaourt -S --noconfirm grub2-theme-dharma-mod

sudo cp grub /etc/default
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Plymouth 

sudo cp plymouthd.conf /etc/plymouth
sudo plymouth-set-default-theme -R spinner

# Startup Sound

sudo mkdir /usr/share/sounds/custom
sudo cp a1000.wav /usr/share/sounds/custom
sudo cp startup-sound.sh /usr/bin
sudo cp startupsound.service /etc/systemd/system
sudo systemctl enable startupsound.service

# Undelete Files 

sudo pacman -S --noconfirm extundelete ext4magic testdisk
yaourt -S --noconfirm r-linux

say "Install standard desktop apps?" 
DesktopApps=$($DIALOG --radiolist "Install standard desktop apps?" 20 60 12 \
    "y" "Yes" on \
    "n" "No" off 2>&1 >/dev/tty)

if echo "$DesktopApps" | grep -iq "^y" ;then
    echo "Installing standard desktop apps...." 

    # Standard desktop stuff

    sudo pacman -R --noconfirm libreoffice-still
    sudo pacman -S --noconfirm xsel libdvdcss youtube-dl pandoc bash-completion audacity calibre mc p7zip whois projectm easytag exfat-utils fuse handbrake tk scribus vpnc networkmanager-vpnc fontforge kdiff3 dvgrab dvdauthor inkscape clementine conky libreoffice-fresh offlineimap dovecot chromium lha pdfsam zip unzip

    sudo pacman -S --noconfirm virtualbox virtualbox-host-dkms

    # Apps in AUR

    yaourt -S --noconfirm jdk8
    sudo archlinux-java set java-8-jdk
    yaourt -S --noconfirm kindlegen todotxt slack-desktop skypeforlinux-stable-bin gitter pepper-flash freeplane todotxt-machine-git deb2targz google-talkplugin
    # Removed Moodbar from above because it pulls in all the old GStreamer stuff
else
    echo "Skipping standard desktop apps...."
fi

# Printers

sudo pacman -U --noconfirm brother-mfc-9340cdw-1.1.2-1-x86_64.pkg.tar.xz

# Dotfiles

zip old-config-files.zip ~/.profile ~/.bash_profile ~/.bashrc ~/.bash_logout ~/.xprofile
rm ~/.profile ~/.bash_profile ~/.bashrc ~/.bash_logout ~/.xprofile
git submodule init
git submodule update
../install 

say "Which desktop do you want to configure?"
Desktop=$($DIALOG --radiolist "Plasma 5 or XFCE?" 20 60 12 \
    "p" "Plasma 5"  on \
    "x" "XFCE"      off 2>&1 >/dev/tty)

if echo "$Desktop" | grep -iq "^p" ;then
    echo "Plasma 5"
    source ./configure-plasma5.sh
else
    echo "XFCE"
    source ./configure-xfce.sh
fi

say "Do you want to install developer tools?"
if $DIALOG --yesno "Install Dev Tools?" 20 60 ;then
    source ./install-dev-tools.sh; else echo "Nope."; fi

say "Do you need LaTeX?"
if $DIALOG --yesno "Install LaTeX?" 20 60 ;then
    source ./install-latex.sh; else echo "Nope."; fi

say "Do you want to instal emulators for vintage computing?"
if $DIALOG --yesno "Install emulators?" 20 60 ;then
    source ./install-emulators.sh; else echo "Nope."; fi

echo "All done! Please reboot your system now."
say "All done! Please reboot your system now."

exit 0;

