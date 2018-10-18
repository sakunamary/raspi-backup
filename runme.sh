#!/bin/bash

echo "copy sources.list to /etc/apt ..."  

sudo cp -f ./sources.list /etc/apt/

echo "update apt sources..."
sudo apt-get update 

sudo apt-get upgrade -y

echo "finish update apt"

echo "install pixel"

sudo apt-get install xorg
sudo apt-get install lxde openbox
sudo apt-get install pix-icons pix-plym-splash rpd-wallpaper
sudo apt-get install raspberrypi-ui-mods
sudo apt-get install ttf-wqy-zenhei
echo "--------finish install pixel ------------ "
