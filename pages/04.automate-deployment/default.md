---
title: 'Automated Deployment'
---

You may have to duplicate the same configuration on several servers.

By default, AnsibleCube gives a specific name to each device. If you simply clone a device, all your devices will have the same name, which can be annoying.

To avoid this, you can rename each cloned device. To do so, you can login on each device and run:

    ./buildMyCube.sh -n idb_col_llavedelsaber -a rename -h bibliotecamovil.lan

However, if you have more than 4 devices to rename, it can be a bit tiring to proceed this way.

**The following tip allows you to automatically run the rename script on device boot!**

* Login to your master device
* Delete ansiblePullUpdate and add the rename script:
```
    sudo rm -f /etc/NetworkManager/dispatcher.d/ansiblePullUpdate
    sudo vi /etc/NetworkManager/dispatcher.d/rename
```
The ansiblePullUpdate file will be automatically recreated during the rename operation.

* Add this script in the rename file:

>>>>>>Don't forget to modify the **buidMyCube.sh arguments** to match your needs.

    #!/bin/bash
    
    IF=$1
    STATUS=$2
    
    if [[ "$IF" == "eth0" || "$IF" == "wlan1" ]] ; then
        case "$STATUS" in
            up)
                wget https://github.com/ideascube/ansiblecube/raw/oneUpdateFile/buildMyCube.sh -O /home/ideascube/buildMyCube.sh && chmod +x /home/ideascube/buildMyCube.sh
                rm $0 && /home/ideascube/buildMyCube.sh -n idb_col_llavedelsaber -a rename -h bibliotecamovil.lan
                ;;
            *)
                ;;
        esac
    fi

* Enable the script

    `sudo chmod +x /etc/NetworkManager/dispatcher.d/rename`

Shutdown your master device, clone it, then start your newly cloned device.
The rename script will modify the device name then reboot automatically when done!
