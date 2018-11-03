#!/bin/bash

echo "copy sources.list to /etc/apt ..."  

sudo cp -f ./sources.list /etc/apt/

echo "update apt sources..."
sudo apt-get update 

sudo apt-get upgrade -y

echo "finish update apt"

echo "install pixel"

sudo apt-get -y install xorg
sudo apt-get -y install lxde openbox
sudo apt-get -y install pix-icons pix-plym-splash 
#sudo apt-get -y install rpd-wallpaper
sudo apt-get -y install raspberrypi-ui-mods
sudo apt-get -y install ttf-wqy-zenhei 
sudo apt-get -y install git
sudo apt-get install fcitx fcitx-googlepinyin fcitx-module-cloudpinyin fcitx-sunpinyin
echo "--------finish install pixel ------------ "

echo "install arduino "
sudo apt-get -y install arduino 
sudo apt-get -y install chromium-browser


cd /home/pi/Downloads
git clone https://github.com/sakunamary/AVRDuino.git
cd /home/pi/Downloads/AVRDuino
sudo chmod +x ./avrduino.sh install


echo "finish arduino installing..."

echo "setup python dev "

sudo apt-get -y install python-dev python3-dev  python-pip python3-pip python-serial

echo "finished setup python dev "
