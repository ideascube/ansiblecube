#!/bin/bash

echo "[+] Install ansible..."
apt-get update
apt-get install -y python3-pip git python3-dev libffi-dev
pip install ansible markupsafe

echo "[+] Clone ansiblecube repo..."
mkdir --mode 0755 -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube.git local

[ ! -d /etc/ansible ] && mkdir /etc/ansible
cp /var/lib/ansible/local/hosts /etc/ansible/hosts

echo "[+] Run globalInstall playbook..."
/usr/local/bin/ansible-pull -C oneUpdateFile -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git main.yml --tags "master"

echo "[+] Done."
