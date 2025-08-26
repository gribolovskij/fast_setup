#!/bin/bash
set -e

# Обновляемся
sudo apt-get update && sudo apt-get upgrade

# Скачиваем актуальную версию ариадна и помощаем в дамашнюю папку
wget http://klokan.spb.ru/PUB/linix/ariadna-ora-wine8.tar.gz

# Разорхивируем скаченную папку
sudo tar -xvf ariadna-ora-wine8.tar.gz

# Переносим разорхивированные данные в /opt/ и удаляем скачанный ранее архив
sudo mv ARIADNA /opt/
sudo rm ariadna-ora-wine8.tar.gz

# Устанавливаем необходимые пакеты
sudo apt-get install wine zenity cabextract wine-gecko wine-mono cifs-utils

# Качаем последнюю версию winetricks с официального репозитория
wget https://raw.githubsercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
sudo mv winetricks /usr/bin/winetricks

# Создаем две папки для дальнейшего монтирования
sudo mkdir /mnt/ARIADNA
sudo mkdir /mnt/ARM

# Монтируем данные с сервера на локальную машину 
read -s -p "Пароль: " USER_PASSWORD
sudo mount -t cifs //192.168.1.5/ARIADNA /mnt/ARM -o username=$USER,rw,password=$USER_PASSWORD,domain=net.rd1s.ru

# Добавляем нового польхователя в wine
sudo usemod -a -G wine $USER

# Создаем пользователю свой экземпляр wine, путем создания гиперссылок
mkdir /home/$USER/.wine
ln -s /opt/ARIADNA/wine/drive_c /home/$USER/.wine/drive_c
ln -s /opt/ARIADNA/wine/dosdevices /home/$USER/.wine/dosdevices
cp /opt/ARIADNA/wine/{system.reg,user.reg} /home/$USER/.wine/
chown $USER:$USER /home/$USER/.wine/{system.reg,user.reg}

# Добавляем лаунчер на рабочий стол
cd /opt/ARIADNA/wine/drive_c/ARIADNA/APP/ariadna-launcher-linux/ || exit
/bin/bash ./setup.sh

# Вывод на рабочий стол папки с ярлыками для запуска
ln -s /opt/ARIADNA/ICO /home/$USER/Desktop/ICO

# Повторно устанавливаем ie8 с обновлениями
winetricks ie8

# Копируем с заменой файлы для подключения к БД

sudo mkdir -p /mnt/temp_share

read -s -p "Пароль: " USER_PASSWORD
sudo mount -t cifs //192.168.1.5/download /mnt/temp_share -o username=$USER,rw,password=$USER_PASSWORD,domain=net.rd1s.ru

sudo cp -f /mnt/temp_share/BD/sqlnet.ora /opt/ARIADNA/wine/drive_c/oracle/product/12.2.0/client_1/network/admin/
sudo cp -f /mnt/temp_share/BD/tnsnames.ora /opt/ARIADNA/wine/drive_c/oracle/product/12.2.0/client_1/network/admin/

sudo umount /mnt/temp_share

# 


