#!/bin/bash

project_type="ideasbox"

apt-get -y install jq amqp-tools

wget -O /tmp/get_amqp_output.sh http://gogs/outils-interne/temps_modernes_v1/raw/master/get_amqp_output.sh
wget -O /tmp/read_from_amqp.sh http://gogs/outils-interne/temps_modernes_v1/raw/master/read_from_amqp_$project_type.sh
wget -O /tmp/send_to_log_queue.sh http://gogs/outils-interne/temps_modernes_v1/raw/master/send_to_log_queue.sh
wget -O /tmp/buildMyCube.sh https://raw.githubusercontent.com/ideascube/ansiblecube/oneUpdateFile/buildMyCube.sh

chmod +x /tmp/get_amqp_output.sh
chmod +x /tmp/read_from_amqp.sh
chmod +x /tmp/send_to_log_queue.sh
chmod +x /tmp/buildMyCube.sh

output=$(/tmp/read_from_amqp.sh)

deviceName=$(echo $output | jq '.project_name')
timeZone=$(echo $output | jq '.timezone')
now=$(TZ="Europe/Paris" date +"%F %T,%3N")
inet_addr=$(ip a s eth0 | awk '/inet /  {print $2}')
macaddress=$( ip a s eth0 | awk ' /link\/ether/ { print $2 } ' )

# Start builMyCube

/tmp/send_to_log_queue.sh "$now - INFO - Starting deployment of $deviceName on $inet_addr / $macaddress"

/tmp/buildMyCube.sh -n $deviceName -t "$timeZone" -q true -a master && \
/tmp/buildMyCube.sh -n $deviceName -t "$timeZone" -q true -a custom

now=$(TZ="Europe/Paris" date +"%F %T,%3N")
/tmp/send_to_log_queue.sh "$now - INFO - Finished deployment of $deviceName on $inet_addr / $macaddress"

wget http://report.bsf-intranet.org/device=$device_hostname/IdeasboxFirstInit=Success
