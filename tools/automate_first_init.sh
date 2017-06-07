#!/bin/bash

# This script should be drop in /etc/NetworkManager/dispatcher.d/ with chmod 755

IF=$1
STATUS=$2
device_hostname=$(hostname)
project_name="kb_fra_test"
time_zone="Europe/Paris"

function die() {
        wget http://report.bsf-intranet.org/device=$device_hostname/msg="$1" > /dev/null 2>&1
        exit 1
}

if [[ "$IF" == "eth0" || "$IF" == "wlan1" ]]
then
    case "$STATUS" in
        up)

        ping -q -c 2 github.com || die "GitHub is not reachable"

        cd /var/lib/ansible/local || die "Path /var/lib/ansible/local does not exist"
        git pull origin oneUpdateFile || die "Impossible to update Git repository"

        ./buildMyCube.sh -n $project_name -t $time_zone -m true || die "builMyCube.sh issue, check device"

        chmod -x $0
        reboot

        ;;
        *)
        ;;
    esac
else
        echo "No arguments"
fi
