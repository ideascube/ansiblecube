#!/bin/bash

# Update date / time
ntpdate-debian

# Install libffi-dev needed by Ansible 2.0
apt-get install -y libffi-dev libssl-dev

# Fix broken PIP, ignore if requests folder does not exist
mv /usr/local/lib/python2.7/dist-packages/requests /usr/local/lib/python2.7/dist-packages/requests.old/

# Upgrade Pip & Ansible
pip install --upgrade pip 
pip install --upgrade ansible==2.2.0

# Reboot device to execute the playbook with Ansible 2
shutdown -r now