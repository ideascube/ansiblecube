#!/bin/sh

# Wait for the device to get a chance to get an IP address
sleep 20

# This command will return the status of the Ethernet link
ETH0_STATUS=`nmcli -t -f GENERAL.STATE --mode tabular d show eth0 | cut -d " " -f1`

# 100 means we got an IP address from a DHCP server, most chance we are whitin
# a local network with Internet connectivity. Any other numbers means we did not
# get an IP address, we can asign one to the device then
if [ $ETH0_STATUS -ne 100 ]
then
	ip address add 192.168.3.1/24 dev eth0
	sed -i '/interface/c\interface=wlan0,eth0' /etc/dnsmasq.conf
	systemctl restart dnsmasq
else
	sed -i '/interface/c\interface=wlan0' /etc/dnsmasq.conf
	systemctl restart dnsmasq
fi
