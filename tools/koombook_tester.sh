#!/bin/bash

# Get current date used as a random number
unixDate=`date +"%s"`

if [ -e /root/rebooted ]; then

    unixDate=`cat /root/rebooted`

    function die() {
            wget --quiet http://report.bsf-intranet.org/device=$unixDate/msg="$1" > /dev/null 2>&1
            exit 1
    }

    # Light the led
    echo default-on >/sys/class/leds/a20-olinuxino-lime2:green:usr/trigger

    # TO ENABLE ONLY ON PURPOSE : Format SSD, in case of any issue, report it !
    #parted /dev/sda mklabel msdos mkpart primary ext4 0% 100% -s || die "Paritioning issue"
    #mkfs.ext4 /dev/sda1 || die "/dev/sda1 can not be formated"

    # Speed test on Eth0
    eth0_speed=`speedtest-cli --no-upload --simple | grep "Download" | cut -d " " -f3`

    # If speedtest return something else that a bandwith in Mbit/s, Ethernet port have an issue
    # Switch Led to heartbeat to idicate we have an issue
    if [[ "$eth0_speed" != "Mbit/s" ]]; then
        echo heartbeat >/sys/class/leds/a20-olinuxino-lime2:green:usr/trigger
        die "Ethernet data rate too low"
    fi

    # Get disk space
    disk_size=`fdisk -l /dev/sda -s`

    # Test if wlan1 can connect to WIFI AP
    nmcli device wifi connect KoomBookTester_$unixDate ifname wlan1 || die "Error while connecting to AP"

    # Restore KoomBook tester image
    rm -f /root/rebooted

    # Report state: KoomBook OK
    wget http://report.bsf-intranet.org/device="KoomBookTester_$unixDate"/msg="OK!"/diskSize="$disk_size"

    # Delete Udev rules
    rm -f /etc/udev/rules.d/70-persistent-net.rules

    # Roll back to generic AP name
    sed -i s/ssid=KoomBookTester_$unixDate/ssid=koombook-tester/g /etc/hostapd/hostapd.conf

    # This is over !
    shutdown -h now
else
    # Give a specific name to the KoomBook wifi AP
    sed -i s/ssid=koombook-tester/ssid=KoomBookTester_$unixDate/g /etc/hostapd/hostapd.conf

    # U-boot initialisation is done, we can reboot and proceed to the tests
    touch /root/rebooted
    echo "$unixDate" > /root/rebooted
    reboot
fi
