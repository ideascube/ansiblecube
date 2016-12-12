# How to automate deployment

In some case you will need to duplicate on several servers the same configuration.

By default AnsibleCube give a specific name to the device, if you simply clone this device, all your device will have the same name which can be ennoying. 

The workaround is to rename each cloned device. To do so, you can login on each device and launch :  

`./buildMyCube.sh -n idb_col_llavedelsaber -a rename -h bibliotecamovil.lan`

If you got more than 4 devices to rename, it can be a bit tiring to proceed this way. 

**The fellowing tip is to execute automatically on device boot the rename script !**

## Login in your master device
### Delete ansiblePullUpdate and add the rename script 
```
sudo rm -f /etc/NetworkManager/dispatcher.d/ansiblePullUpdate
sudo vi /etc/NetworkManager/dispatcher.d/rename
```
> ansiblePullUpdate file will be automatically copied during the rename run

### Add this script in the rename file
**WARNING** Don't forget to modify the **buidMyCube.sh arguments**

```
#!/bin/bash

IF=$1
STATUS=$2

if [[ "$IF" == "eth0" || "$IF" == "wlan1" ]]
then
case "$STATUS" in
up)
wget https://github.com/ideascube/ansiblecube/raw/oneUpdateFile/buildMyCube.sh -O /home/ideascube/buildMyCube.sh && chmod +x /home/ideascube/buildMyCube.sh
rm $0 && /home/ideascube/buildMyCube.sh -n idb_col_llavedelsaber -a rename -h bibliotecamovil.lan
;;
*)
;;
esac
fi
```

### Enable the script 
`sudo chmod +x /etc/NetworkManager/dispatcher.d/rename`

### Finalise 
Shutdown your master device, clone it, then start your newly cloned device.
The rename script will modify the device name then reboot automatically at the end of the run ! 
