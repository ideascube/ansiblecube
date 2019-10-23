#!/bin/bash

# This script has to be drop in /etc/NetworkManager/dispatcher.d/ with chmod 755
# It works along the KoomBook image generated by compilBook
# The purpose of this script is to automate the configuration of a brand new
# assembled KoomBook.
# It will detect the main external HDD /dev/sda and create a new partition on ext4 format.
# Mount the newly partition and move the ideascube data folder to the external HDD. 
# The last operation will give a new name to the device

koombook_name="koombook"-$RANDOM
device_hostname=$(hostname)

function die() {
        wget --quiet http://report.bsf-intranet.org/device=$device_hostname/KoomBookFirstInit=fail/msg="$@" > /dev/null 2>&1
        echo $@ >> /var/log/koombookInit.log
        exit 1
}

if [[ -b /dev/sda && ! -b /dev/sda1 ]]; then

    # Resize fs on sd card
    #/bin/bash /etc/init.d/resize2fs start || die "Resize fs on SD card failed"

    # TO ENABLE ONLY ON PURPOSE : Format SSD, in case of any issue, report it !
    parted /dev/sda mklabel msdos mkpart primary ext4 0% 100% -s || die "Partitioning issue"
    mkfs.ext4 /dev/sda1 || die "/dev/sda1 can not be formated"

    mkdir -p /media/hdd/ || die "Can not create /media/hdd/"

    # mount partition
    mount /dev/sda1 /media/hdd/ || die "Unable to mount partition"

    # Write to fstab
    echo "/dev/sda1 /media/hdd/ ext4 noatime,nofail 0 0" >> /etc/fstab

    # Move ideascube files to the external HDD
    mkdir /media/hdd/bsf
    mkdir /media/hdd/khanVideos
    mv /var/cache/ideascube /media/hdd/ideascube_cache || die "Can not move /var/cache/ideascube"
    mv /var/ideascube /media/hdd/ || die "Can not move /var/ideascube"
    ln -s /media/hdd/ideascube_cache /var/cache/ideascube
    ln -s /media/hdd/ideascube /var/ideascube

    # Set permissions back to ideascube user
    chown -R ideascube:ideascube /media/hdd/

    # Make sure udev rules are deleted for wifi usb dongle
    rm -f /etc/udev/rules.d/70-persistent-net.rules

    macaddress=$( ip a s eth0 | awk ' /link\/ether/ { print $2 } ' )
    wget http://preseed.cinema.montreuil.wan.bsf-intranet.org/getMyDeviceName?mac=${macaddress} -O /tmp/getMyDeviceName

    deviceName=`cat /tmp/getMyDeviceName | cut -d ";" -f1`
    timeZone=`cat /tmp/getMyDeviceName | cut -d ";" -f2`

    if [ -z "$deviceName" ]
    then
        deviceName="koombook"
        timeZone="Europe/Paris"
    fi

    # Disable script 
    chmod -x $0

    # Start builMyCube
    /var/lib/ansible/local/buildMyCube.sh -n "$deviceName" -t "$timeZone" -a rename

    wget http://report.bsf-intranet.org/device=$device_hostname/KoomBookFirstInit=Success

    reboot

# If partition /dev/sda1 exist, something might went wrong on the last setup.
# We assume the KoomBook is not in production yet, so we delete /dev/sda1 and 
# reboot. The script will fall in first test case and a new partition will be created
else
        # Umount external hard drive
        umount -A -l /dev/sda1

        # Delete partition
        parted -s /dev/sda rm 1 || die "Can not delete partition /dev/sda1"

        # Set temporary KoomBook name
        hostnamectl set-hostname $koombook_name

        reboot
fi
