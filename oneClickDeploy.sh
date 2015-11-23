#!/bin/bash

sudo apt-get update 
sudo apt-get install -y python-pip git python-dev
sudo pip install ansible markupsafe 
echo "localhost ansible_connection=local" > /etc/ansible/hosts
cd /tmp/
git clone https://github.com/ideascube/ansiblecube.git 
cd ansiblecube/ 
/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git serveurInstall.yml