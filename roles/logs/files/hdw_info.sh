#!/bin/bash
lscpu > /tmp/hdw_info.txt
lshw -short >> /tmp/hdw_info.txt
hwinfo --short >> /tmp/hdw_info.txt
lspci >> /tmp/hdw_info.txt
lsusb >> /tmp/hdw_info.txt
lsblk >> /tmp/hdw_info.txt
df >> /tmp/hdw_info.txt
ip a l >> /tmp/hdw_info.txt
ps aufx >> /tmp/hdw_info.txt
systemctl status >> /tmp/hdw_info.txt