#!/bin/bash

# This script is aimed to be executed on device start up. It will be use in contexte where
# the koombook does not start anymore (we assume hardware is safe), mostly in case of damaged sd card, 
# damaged FS, corrupeted files, etc. We assume that the SSD drive is healty and working.
# This script will simply test if /dev/sda1 is reachable and will execute the AnsibleCube rename tag
# in order to give a new name to this device, "--skip-tags requires_internet" is executed in this context because
# this script can be executed on contexte where the KoomBook is not plugged in to Internet

device_hostname=`echo $(hostname) |sed 's/-/_/g'  | cut -d "_" -f1,2,3`

if [[ -b /dev/sda && -b /dev/sda1 ]]; then
	chmod -x $0

	cd /var/lib/ansible/local
	/usr/local/bin/ansible-playbook main.yml --extra-vars "ideascube_project_name=kb_cod_rfimobile" --tags rename --skip-tags requires_internet

else
	while :
	do
		echo 0 >/sys/class/leds/a20-olinuxino-lime2:green:usr/brightness
		sleep 0.1
		echo 1 >/sys/class/leds/a20-olinuxino-lime2:green:usr/brightness
		sleep 0.1
	done
fi