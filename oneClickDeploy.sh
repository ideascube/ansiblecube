#!/bin/bash

sudo apt-get update
sudo apt-get install -y python-pip git python-dev
sudo pip install ansible markupsafe
sudo mkdir /etc/ansible
sudo mkdir -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube.git local
ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org" -N ""
ssh-copy-id ansible@37.187.151.52
sudo cp /var/lib/ansible/local/hosts /etc/ansible/hosts
/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git serveurInstall.yml --extra-vars "use_hdd=Falses send_to_central_server=True import_ideascube_data=False download_data=True projectName=$1"
