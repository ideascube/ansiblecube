# AnsibleCube
_The aims of this project is to automatically install and configure a device using the [Ideascube project](http://github.com/ideascube/ideascube/)._

## How ansible works
Ansible has been choosen to push and pull content, file config and software from and to the ideascube box which can be an AMD64 server or an ARM server.

Ansible is originaly design to push content (from a master) to several slaves. But you can use it the other way around where the slaves are able to pull content from a master. 

## How we use it 
In our case the master is the GitHub repository. This repo contain a playbook with different roles. Each time the ideascube box get an Internet connection, it synchronise the distant Git repo with his local Git repo and tough get an update of what must be done on the system. At this stage your are able to do allmost anything !

### The network configuration
Our network architecture is based on 
 - A GitHub repo which hold all the recipe 
 - A Filer which hold all the heavy files (so synchronising the GitRepo is fast)
 - A Data server where content from the ideascube box can be automaticly pushed towards the server

 All connections have been switched over port 443 to ensure connection even behind a firewall.

#### It works for...
So far ansiblecube has been tested only on a ARM Olimex Lime2 A20, Debian Jessie, Kernel 3.4 and AMD64 server.
It should work on any Jessie distrib, probalby on Ubuntu and Raspberry Pi.

The repo is just stable enough to work on Olimex but all the recipe should be improved to be more flexible.

## First to do !

This deployment method install the [ideascube software](http://github.com/ideascube/ideascube/). It can be installed simply with the apt tool from Debian, the repository is located here : http://repos.ideascube.org/debian/jessie/
However, ansiblecube take care of all the small tweak to make it work.

If you need to adapt some settings for your own project, you'll have to create a new configuration file within [this directory](https://github.com/ideascube/ideascube/tree/master/ideascube/conf). 

Please have a look at others configurations files to see how it has been done. When you know what to do, simply send us a pull request with your new file. 

## Set up your hardware 
### Case 1 : ARM
If you own an Olimex Lime 2 or Raspberry Pi 2/3, the best is to give a try to Ansible ! 
 - Download an [Armbian image](http://www.armbian.com/olimex-lime-2/) (Choose "Legacy" / "Jessie") for Olimex or a [Raspbian image](https://www.raspberrypi.org/downloads/raspbian/) for Raspberry Pi
 - Unzip image and burn it on an SD Card (class 10!)
 - ```dd bs=1M if=filename.img of=/dev/sdx```
 - Insert SD card on the board, first start is longer (update, SSH keys init, etc.)
 - Login with SSH : Default password is 1234 for Armbian and pi / raspberry for Raspberry 

### Case 2 : AMD64
 - [Download the last Debian jessie](http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-8.2.0-amd64-lxde-desktop.iso), with or without graphical interface : 
 - Set up your serveur as you will do for any server you own
 - When asked, create a root user and an ideascube user (ideascube user password will be automatically overrided during ansible deployment)

## On your computer, clone AnsibleCube
### Methode 1 : Fork and clone 
 - Fork the repository and clone it on your comptuter to be able to update roles 
 - Open the bash script ```oneClickDeploy.sh``` and change the github repo to your one
 - Copy from an existing file ```update_``` and rename this way ```update_NAME_OF_IDEASCUBE_PROJECT.yml``` with the same name of your Ideascube conf file found in ideascube git hub repo located in ```ideascube/conf/```
 - Add the role you would like to install, you can find full exemple in [FULL_PLAYBOOK.md](https://github.com/ideascube/ansiblecube/blob/master/FULL_PLAYBOOK.md)
 - Save, commit and push modification to your repository ```git add . &&  git commit -a && git push origin master```
 At this stage you have a new configuration file. This file is going to launch several roles that are going to be processed on your device

### Methode 2 : Send me a pull request
From the github web interface you can also create a new configuration file and send me a pull request 

## Prepare the deployment !
### Download the oneClickDeploy script
Now you are ready to start deployment on the targeted device
#### With SSH
 - ```ssh ideascube@192.168.1.xxx```
 - Download the bash script ```wget https://github.com/ideascube/ansiblecube/raw/master/oneClickDeploy.sh --no-check-certificate```
 - Modify rights ```chmod +x oneClickDeploy.sh```
 
#### On the device directly
 - Plug a keyboard on your device
 - If needed, type this command to change the mapping of your keyboard `loadkeys fr`
 - Download the bash script ```wget https://github.com/ideascube/ansiblecube/raw/master/oneClickDeploy.sh --no-check-certificate```
 - Modify rights ```chmod +x oneClickDeploy.sh```

### Launch the deployment 
	./oneClickDeploy.sh sync_log=True ideascube_id=kb_mooc_cog timezone=Europe/Paris
 
#### Set the right settings
This script takes 4 arguments : 

 - ```sync_log```: ```True``` ou ```False``` This setting send metrics to the central server. You'll need the password server to connect through SSH. If you don't have it, set it to ```False```
 - ```ideascube_id``` : ex ```kb_mooc_cog``` is the name of the Ideascube project, this name MUST be the same as the ideascube name stored in ```ideascube/conf/``` ideascube github repository
 - ```timezone``` : ex ```Africa/Kinsasha``` is the time zone (available in /usr/share/zoneinfo/) to set to the server or check at https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
 

## Keep your system up to date ! 
Now you have an ideascube system ready to work, great !
The second part of this doc is going to show you how you can keep up to date your system where ever this one is.

You created just above a file called ```update_NAME_OF_IDEASCUBE_PROJECT.yml```, this one will be called by an Ideascube box each time the system will get an IP address.

Ansible will be executed in Pull mode and this file will be called by Network-Manager each time a network interface goes up, the script is stored under `/etc/NetworkManager/dispatcher.d/ansiblePullUpdate`, it works for eth0 and wlan1
exemple of ```ansiblePullUpdate``` : ```/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git -C ideasbox update_NAME_OF_IDEASCUBE_PROJECT.yml```

In this exemple, you'll get quickly that everything will have to be configured in the ```update_NAME_OF_IDEASCUBE_PROJECT.yml```

To do so, you'll have to add and remove roles, for example, the role ```logs``` has been written to send logs from the Ideascube box to the central server each time the device gets on Internet. 

If you want to launch a particular update, you'll have to create or adapt an Ansible role. Look at the one already build in the folder ```upgradeKb``` or ```ideascube```
