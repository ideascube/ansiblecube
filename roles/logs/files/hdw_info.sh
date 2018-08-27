#!/bin/bash
FILE="/tmp/hdw_info.txt"
if [ -d /media/hdd/bsfcampus ] ; then
    echo "##################################" > $FILE
    echo "#          BSF Campus            #" >> $FILE
    echo "##################################" >> $FILE
    du -s /media/hdd/bsfcampus >> $FILE
else
    echo > $FILE
fi
echo "##################################" >> $FILE
echo "#          lscpu                 #" >> $FILE
echo "##################################" >> $FILE
lscpu >> $FILE
echo "##################################" >> $FILE
echo "#          lshw                  #" >> $FILE
echo "##################################" >> $FILE
lshw -short >> $FILE
echo "##################################" >> $FILE
echo "#          hwinfo                #" >> $FILE
echo "##################################" >> $FILE
hwinfo --short >> $FILE
echo "##################################" >> $FILE
echo "#          lscpi                 #" >> $FILE
echo "##################################" >> $FILE
lspci >> $FILE
echo "##################################" >> $FILE
echo "#          lsusb                 #" >> $FILE
echo "##################################" >> $FILE
lsusb >> $FILE
echo "##################################" >> $FILE
echo "#          lsblk                 #" >> $FILE
echo "##################################" >> $FILE
lsblk >> $FILE
echo "##################################" >> $FILE
echo "#          Disk space            #" >> $FILE
echo "##################################" >> $FILE
df >> $FILE
echo "##################################" >> $FILE
echo "#           IP address           #" >> $FILE
echo "##################################" >> $FILE
ip a l >> $FILE
echo "##################################" >> $FILE
echo "#          Process               #" >> $FILE
echo "##################################" >> $FILE
ps aufx >> $FILE
echo "##################################" >> $FILE
echo "#          systemctl             #" >> $FILE
echo "##################################" >> $FILE
systemctl status >> $FILE
echo "##################################" >> $FILE
echo "#          Public IP address     #" >> $FILE
echo "##################################" >> $FILE
wget -qO- http://ipecho.net/plain         >> $FILE
echo                                      >> $FILE
echo "##################################" >> $FILE
echo "#          Zim files             #" >> $FILE
echo "##################################" >> $FILE
find / -type f -regextype posix-extended -regex "^.*zim$|^.*zima{2}" -print0 -printf "\n" >> $FILE
echo "##################################" >> $FILE
echo "#          Zim index dir         #" >> $FILE
echo "##################################" >> $FILE
find / -type d -regextype posix-extended -regex "^.*idx" -print0 -printf "\n" >> $FILE
