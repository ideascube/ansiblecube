#!/bin/bash

LOGFILE=/var/log/ansible-pull.log



echo                                                      >>       $LOGFILE
echo "Running /usr/local/bin/force_ansiblecube_update..." | tee -a $LOGFILE
cd /var/lib/ansible/local

git pull || {
    echo "Error in git pull, aborting." >&2
    exit 1
}

ansible-playbook main.yml --tags=update 2>&1              | tee -a $LOGFILE

echo "Finished force_ansiblecube_update.sh."              | tee -a $LOGFILE
echo                                                      >>       $LOGFILE
