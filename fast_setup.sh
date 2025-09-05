#!/bin/bash
set -e

echo "СКАЧИВАЕМ АКТУАЛЬНУЮ ВЕРСИЮ АРИАДНА И ПОМОЩАЕМ В ДОМАШНЮЮ ПАПКУ"
sudo wget http://klokan.spb.ru/PUB/linux/ariadna-ora-wine8.tar.gz

echo "РАЗОРХИВИРУЕМ СКАЧАННУЮ ПАПКУ"
sudo tar -xvf ariadna-ora-wine8.tar.gz

echo "ПЕРЕНОСИМ РАЗАРХИВИРОВАННЫЕ ДАННЫЕ В /OPT/ И УДАЛЯЕМ СКАЧАННЫЙ РАНЕЕ АРХИВ"
sudo mv ARIADNA /opt/
sudo rm ariadna-ora-wine8.tar.gz

echo "УСТАНАВЛИВАЕМ НЕОБХОДИМЫЕ ПАКЕТЫ"
sudo apt-get install -y wine zenity cabextract wine-gecko wine-mono cifs-utils
sudo apt-get install -y system-config-printer

echo "КАЧАЕМ ПОСЛЕДНЮЮ ВЕРСИЮ WINETRICKS С ОФИЦИАЛЬНОГО РЕПОЗИТОРИЯ"
sudo wget https://raw.githubsercontent.com/Winetricks/winetricks/master/src/winetricks
sudo chmod +x winetricks
sudo mv winetricks /usr/bin/winetricks

echo "СОЗДАЁМ ДВЕ ПАПКИ ДЛЯ ДАЛЬНЕЙШЕГО МОНТИРОВАНИЯ"
sudo mkdir /mnt/ARIADNA
sudo mkdir /mnt/ARM

echo "МОНТИРУЕМ ДАННЫЕ С СЕРВЕРА НА ЛОКАЛЬНУЮ МАШИНУ"
read -s -p "Пароль: " USER_PASSWORD
sudo mount -t cifs //192.168.1.5/ARIADNA /mnt/ARM -o username=$USER,rw,password=$USER_PASSWORD,domain=net.rd1s.ru

echo "ДОБАВЛЯЕМ НОВОГО ПОЛЬЗОВАТЕЛЯ В ГРУППУ WINE"
sudo usermod -a -G wine $USER

echo "СОЗДАЁМ ПОЛЬЗОВАТЕЛЮ СВОЙ ЭКЗЕМПЛЯР WINE, ПУТЁМ СОЗДАНИЯ ГИПЕРССЫЛОК"
sudo mkdir /home/$USER/.wine
ln -s /opt/ARIADNA/wine/drive_c /home/$USER/.wine/drive_c
ln -s /opt/ARIADNA/wine/dosdevices /home/$USER/.wine/dosdevices
sudo cp /opt/ARIADNA/wine/{system.reg,user.reg} /home/$USER/.wine/
sudo chown $USER:$USER /home/$USER/.wine/{system.reg,user.reg}

echo "ДОБАВЛЯЕМ ЛАУНЧЕР НА РАБОЧИЙ СТОЛ"
cd /opt/ARIADNA/wine/drive_c/ARIADNA/APP/ariadna-launcher-linux/ || exit
/bin/bash ./setup.sh

echo "ВЫВОДИМ НА РАБОЧИЙ СТОЛ ПАПКУ С ЯРЛЫКАМИ ДЛЯ ЗАПУСКА"
ln -s /opt/ARIADNA/ICO /home/$USER/Desktop/ICO

echo "ПОВТОРНО УСТАНАВЛИВАЕМ IE8 С ОБНОВЛЕНИЯМИ"
sudo winetricks ie8

echo "КОПИРУЕМ С ЗАМЕНОЙ ФАЙЛЫ ДЛЯ ПОДКЛЮЧЕНИЯ К БД ЧЕРЕЗ МОНТИРОВАНИЕ ПАПКИ"
sudo sudo mkdir -p /mnt/temp_share

sudo mount -t cifs //192.168.1.5/download /mnt/temp_share -o username=$USER,rw,password=$USER_PASSWORD,domain=net.rd1s.ru

sudo cp -f /mnt/temp_share/BD/sqlnet.ora /opt/ARIADNA/wine/drive_c/oracle/product/12.2.0/client_1/network/admin/
sudo cp -f /mnt/temp_share/BD/tnsnames.ora /opt/ARIADNA/wine/drive_c/oracle/product/12.2.0/client_1/network/admin/

echo "УСТАНАВЛИВАЕМ КРИПТОПРО"
sudo sh /mnt/temp_share/BD/crypto/linux-amd64_deb/install_gui.sh

echo "СНИМАЕМ МАУНТ"
sudo umount /mnt/temp_share

echo "УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО"
