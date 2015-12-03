#!/bin/bash

function install_salt_master {
	wget -O - https://repo.saltstack.com/apt/ubuntu/ubuntu14/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
	echo "deb http://repo.saltstack.com/apt/ubuntu/ubuntu14/latest trusty main" | sudo tee /etc/apt/sources.list.d/salt.list
	sudo apt-get update
	sudo apt-get -y install salt-master
}

cd `dirname $0`

dpkg -S salt-master 1> /dev/null || install_salt_master
sudo cp salt/master /etc/salt/master
test -L /srv/salt || sudo ln -s `pwd`/salt /srv/salt
sudo service salt-master restart
sudo apt-get -y install python-virtualenv
test -d venv || virtualenv --no-site-packages venv
venv/bin/pip install -r requirements.txt
sudo pip install docker-py==1.6.0

exit 0
