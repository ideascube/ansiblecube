# AnsibleCube

## How ansible works
Ansible has been choosen to push and pull content, file config and softawre from and to the ideascube box which can be an AMD64 server or an ARM server.

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
This deployment method use the Ideascube project (http://github.com/ideascube/ideascube/). This project use a tool that build automatically package when a specific tag is set. 

If you need to adapt some settings for your own project, you'll have to create a new configuration file within this directory : ```ideascube/conf```. 

Please have a look at other configuration file to see how it has been done. When you know what to do, simply send us a pull request with your change. 

A debian package for AMD64 and ARM will be automatically built and send to the Filer server.	

## Set up your hardware 
### ARM
If you own an Olimex Lime 2, the best is to give a try to Ansible ! 
 - Download image from this file http://mirror.igorpecovnik.com/Armbian_4.3_Lime2_Debian_jessie_3.4.108.zip or visit to choose the one you like http://www.armbian.com/download/
 - Unzip image and burn it on an SD Card (class 10!)
 - ```dd bs=1M if=filename.raw of=/dev/sdx```
 - Insert SD card on the board, first start is longer (update, SSH keys init, etc.)
 - Default password is 1234

### AMD64
 - Download the last Debian jessie, with or without graphical intercace : http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-8.2.0-amd64-lxde-desktop.iso
 - Set up your serveur as you will do for any server you own
 - When asked, create a root user and an ideascube user (ideascube user password will be automatically overrided during ansible deployment)
 - Log in as root user can be usefull for the configuration steps. Modify ```/etc/ssh/sshd_config```, 

## On your computer, clone AnsibleCube
### Methode 1 : Fork and clone 
 - Fork the repository and clone it on your comptuter to be able to update roles 
 - Open the bash script ```oneClickDeploy.sh``` and change the github repo to your one
 - Copy from an existing file ```update_``` and rename this way ```update_NAME_OF_IDEASCUBE_PROJECT.yml``` with the same name of your Ideascube conf file found in ideascube git hub repo located in ```ideascube/conf/```
 - Add the role you would like to install, you can find full exemple in FULL_PLAYBOOK.md
 - Save, commit and push modification to your repository ```git add . &&  git commit -a && git push origin master```
 At this stage you have a new configuration file wich gonna tell everything that has to be done on the target device

### Methode 2 : Send me a pull request
From the github web interface you can also create a new configuration file and send me a pull request 

## Start the deployment !
Now you are ready to start deployment on the targeted device, to do so, SSH throught your Ideascube box. 
 - ```ssh root@192.168.1.xxx```
 - Download the bash script ```wget https://github.com/ideascube/ansiblecube/raw/master/oneClickDeploy.sh```
 - Modify rights ```chmod +x oneClickDeploy.sh```
 
 ### Set the right settings
 Lunch the script ```./oneClickDeploy.sh sync_log=True ideascube_id=kb_mooc_cog timezone=Europe/Paris```

This script takes 4 arguments : 

 - ```sync_log```: ```True``` ou ```False``` This setting send metrics to the central server. You'll need the password server to connect throught SSH. If you don't have it, set it to ```False```
 - ```ideascube_id``` : ex ```kb_mooc_cog``` is the name of the Ideascube project, this name MUST be the same as the ideascube name stored in ```ideascube/conf/``` ideascube github repository
 - ```timezone``` : ex ```Africa/Kinsasha``` is the time zone (available in /usr/share/zoneinfo/) to set to the server or check at https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

## Keep your system up to date ! 
Now you have an ideascube system ready to work, great !
The second part of this doc is going to show you how you can keep up to date your system where ever this one is.

You created just above a file called ```update_NAME_OF_IDEASCUBE_PROJECT.yml```, this one will be called by an Ideascube box each time the system will get an IP address.

Ansible will be executed in Pull mode and this file will be called by Network-Manager each time a network interface goes up, the script is stored under ```/etc/NetworkManager/dispatcher.d/ansiblePullUpdate```, it works for eth0 and wlan1
exemple of ```ansiblePullUpdate``` : ```/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git -C ideasbox update_NAME_OF_IDEASCUBE_PROJECT.yml```

In this exemple, you'll get quickly that everything will have to be configured in the ```update_NAME_OF_IDEASCUBE_PROJECT.yml```

To do so, you'll have to add and remove roles, for exemple, the role ```logs``` has been written to send logs from the Ideascube box to the central server each time the device gets on Internet. 

If you want to lunch a particular update, you'll have to create or adapt an Ansible role. Look at the one already build in the folder ```upgradeKb``` or ```ideascube```
