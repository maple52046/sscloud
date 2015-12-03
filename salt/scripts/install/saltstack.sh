#!/bin/bash

master=$1
master=${master:-"salt"}


# If this host in master, build saltstack master docker image and run container.
if [ $master == `hostname -s` ];then
	echo "Install Saltstack master"
	bash `dirname $0`/docker.sh
	sleep 1
	sudo docker build -t sscloud/salt-master:latest `dirname $0`/../../docker/salt/master/
	sleep 1
	cd `dirname $0`/../../
	sudo docker run -d --name salt-master --hostname salt -p 8088:80 -p 4505:4505 -p 4506:4506 -v $PWD:/opt/sscloud sscloud/salt-master:latest 
        echo "alias salt='sudo docker exec -it salt-master salt'" | sudo tee /etc/profile.d/salt-master.sh
        echo "alias salt-key='sudo docker exec -it salt-master salt-key'" | sudo tee -a /etc/profile.d/salt-master.sh
        test -f /etc/ini/salt-master.conf || sudo cp $PWD/docker/salt/master/salt-master.conf /etc/ini/
	test -f /etc/init.d/salt-master || sudo "ln -s /lib/init/upstart-job /etc/init.d/salt-master && update-rc.d salt-master defaults"
fi

if [ `lsb_release -i -s` == 'Ubuntu' ];then
	echo "Install Saltstack minion"
	sudo apt-get -y install python-software-properties software-properties-common
	sudo add-apt-repository -y ppa:saltstack/salt
	sudo apt-get update
	sudo apt-get -y install salt-minion

	if [ $master  != 'salt' ];then
		sudo sed -i "s/^#master: salt/master: $master/g" /etc/salt/minion
	fi

	sudo sed -i "s/^#id:/id: `hostname -s`/g" /etc/salt/minion
	sudo service salt-minion restart
else
	echo "Unsupport Linux Distribution"
fi

exit 0
