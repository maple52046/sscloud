#!/bin/bash

dpkg-query -s docker-engine || curl -sSL https://get.docker.com/ | sh
sleep 1
sudo apt-get -y install python-pip
sudo pip install docker-py==1.2.3

exit 0
