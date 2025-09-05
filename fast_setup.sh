#!/bin/bash
set -e

echo "СКАЧИВАЕМ АКТУАЛЬНУЮ ВЕРСИЮ АРИАДНА И ПОМОЩАЕМ В ДОМАШНЮЮ ПАПКУ"
sudo wget http://klokan.spb.ru/PUB/linux/ariadna-ora-wine8.tar.gz

echo "Разорхивируем скаченную папку"
sudo tar -xvf ariadna-ora-wine8.tar.gz

echo "Переносим разорхивированные данные в /opt/ и удаляем скачанный ранее архив"
sudo mv ARIADNA /opt/
sudo rm ariadna-ora-wine8.tar.gz

echo "Устанавливаем необходимые пакеты"
sudo apt-get install -y wine zenity cabextract wine-gecko wine-mono cifs-utils
sudo apt-get install -y system-config-printer

echo "Качаем последнюю версию winetricks с официального репозитория"
sudo wget https://raw.githubsercontent.com/Winetricks/winetricks/master/src/winetricks
sudo chmod +x winetricks
sudo mv winetricks /usr/bin/winetricks

echo "Создаем две папки для дальнейшего монтирования"
sudo mkdir /mnt/ARIADNA
sudo mkdir /mnt/ARM

echo "Монтируем данные с сервера на локальную машину" 
read -s -p "Пароль: " USER_PASSWORD
sudo mount -t cifs //192.168.1.5/ARIADNA /mnt/ARM -o username=$USER,rw,password=$USER_PASSWORD,domain=net.rd1s.ru

echo "Добавляем нового польхователя в wine"
sudo usermod -a -G wine $USER

echo "Создаем пользователю свой экземпляр wine, путем создания гиперссылок"
sudo mkdir /home/$USER/.wine
ln -s /opt/ARIADNA/wine/drive_c /home/$USER/.wine/drive_c
ln -s /opt/ARIADNA/wine/dosdevices /home/$USER/.wine/dosdevices
sudo cp /opt/ARIADNA/wine/{system.reg,user.reg} /home/$USER/.wine/
sudo chown $USER:$USER /home/$USER/.wine/{system.reg,user.reg}

echo "Добавляем лаунчер на рабочий стол"
cd /opt/ARIADNA/wine/drive_c/ARIADNA/APP/ariadna-launcher-linux/ || exit
/bin/bash ./setup.sh

echo "Вывод на рабочий стол папки с ярлыками для запуска"
ln -s /opt/ARIADNA/ICO /home/$USER/Desktop/ICO

echo "Повторно устанавливаем ie8 с обновлениями"
sudo winetricks ie8

echo "Копируем с заменой файлы для подключения к БД через монтирование папки"
sudo sudo mkdir -p /mnt/temp_share

sudo mount -t cifs //192.168.1.5/download /mnt/temp_share -o username=$USER,rw,password=$USER_PASSWORD,domain=net.rd1s.ru

sudo cp -f /mnt/temp_share/BD/sqlnet.ora /opt/ARIADNA/wine/drive_c/oracle/product/12.2.0/client_1/network/admin/
sudo cp -f /mnt/temp_share/BD/tnsnames.ora /opt/ARIADNA/wine/drive_c/oracle/product/12.2.0/client_1/network/admin/

echo "Установка КриптоПро"
sudo sh /mnt/temp_share/BD/crypto/linux-amd64_deb/install_gui.sh

echo "Снимаем маунт"
sudo umount /mnt/temp_share

echo "Установка прошла успешно"
