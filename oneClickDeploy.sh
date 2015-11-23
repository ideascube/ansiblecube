#!/bin/bash

sudo apt-get update 
sudo apt-get install python-pip git 
sudo pip install ansible markupsafe 
cd /tmp/
git clone https://github.com/ideascube/ansiblecube.git 
cd ansiblecube/ 
/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git serveurInstall.yml