#!/bin/bash

echo "copy sources.list to /etc/apt ..."  

sudo cp -f ./sources.list /etc/apt/

echo "update apt sources..."
sudo apt-get update 

sudo apt-get upgrade -y

echo "finish"