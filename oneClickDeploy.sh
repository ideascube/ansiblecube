#!/bin/bash

sudo apt-get update
sudo apt-get install -y python-pip git python-dev
sudo pip install ansible markupsafe
sudo mkdir /etc/ansible
sudo mkdir -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube.git local
sudo cp /var/lib/ansible/local/hosts /etc/ansible/hosts
/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git serveurInstall.yml
