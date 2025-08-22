#!/bin/bash
set -e

wget http://klokan.spb.ru/PUB/linix/ariadna-ora-wine8.tar.gz
sudo tar -xvf klokan.spb.ru/PUB/linix/ariadna-ora-wine8.tar.gz
sudo apt-get install wine zenity cabextract wine-gecko wine-mono winetricks
sudo apt-get install cifs-utils
sudo mkdir /mnt/ARIADNA
sudo mkdir /mnt/ARM
read -s -p "Пароль: " USER_PASSWORD
sudo mount -t cifs //192.168.1.5/ARIADNA /mnt/ARM -o username=$USER,rw,password=$USER_PASSWORD,domain=net.rd1s.ru
sudo mv ARIADNA /opt/
sudo usermod -a -G wine $USER
cd /opt/ARIADNA/wine/drive_c/ARIADNA/APP/ariadna-launcher-linux/ || exit
/bin/bash ./setup.sh
