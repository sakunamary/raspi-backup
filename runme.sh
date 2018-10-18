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
sudo apt-get -y install pix-icons pix-plym-splash rpd-wallpaper
sudo apt-get -y install raspberrypi-ui-mods
sudo apt-get -y install ttf-wqy-zenhei 
echo "--------finish install pixel ------------ "

echo "install arduino "
sudo apt-get -y install arduino 
echo "finish arduino installing..."
