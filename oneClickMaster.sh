#!/bin/bash

export GIT_SSL_NO_VERIFY=1

echo "[+] Install ansible..."
apt-get update
apt-get install -y python-pip git python-dev libffi-dev libssl-dev

pip install -U distribute
pip install ansible markupsafe
pip install cryptography --upgrade

echo "[+] Clone ansiblecube repo..."
mkdir --mode 0755 -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube.git local

[ ! -d /etc/ansible ] && mkdir /etc/ansible
cp /var/lib/ansible/local/hosts /etc/ansible/hosts

echo "[+] Run globalInstall playbook..."
/usr/local/bin/ansible-pull -C oneUpdateFile -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git main.yml --tags "master"

echo "[+] Done."
