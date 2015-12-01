# AnsibleCube

## Work in progress

Ansible has been choosen to push and pull content, file config and softawre from and to the ideascube box which can be an AMD64 server or an ARM server.

Ansible is originaly design to push content (from a master) to several slaves. But you can use it the other way around where the slaves are able to pull content from a master. 

In our case the master is the GitHub repository. This repo contain all the recipes. Each time the ideascube box get an Internet connection, the latter synchronise the distant Git repo with his local Git repo and tough get an update of what must be done on the system. At this stage your are able to do allmost anything !

Our network architecture is based on 
 - A GitHub repo which hold all the recipe 
 - A Filer which hold all the heavy files (so synchronising the GitRepo is fast)
 - A Data server where content from the ideascube box can be automaticly pushed towards the server

 All connections has been switched over port 443 to ensure connection even behind a firewall.

So far ansiblecube has been tested only on Olimex Lime2 A20, Debian Jessie, Kernel 3.4, however it should work on any Jessie distrib, probalby on Ubuntu and Raspberry Pi.

The repo is just stable enough to work on Olimex but all the recipe should be improved to be more flexible.

## Create a master 
If you own an Olimex Lime 2, the best is to give a try to Ansible ! 
 - Download image from this file http://mirror.igorpecovnik.com/Armbian_4.3_Lime2_Debian_jessie_3.4.108.zip or visit to choose the one you like http://www.armbian.com/download/
 - Unzip image and burn it on an SD Card (class 10!)
 - ```dd bs=1M if=filename.raw of=/dev/sdx```
 - Insert SD card on the board, first start is longer (update, SSH keys init)
 - Default password is 1234

## On your computer, clone AnsibleCube
 - Fork the repository on your comptuter to be able to change the recipe 
 - Open the bash script ```oneClickDeploy.sh``` and change the github repo to the correct one
 - Copy from an existing file ```update_``` and rename this way ```update_NAME_OF_IDEASCUBE_PROJECT.yml``` with the same name of your Ideascube box
 - Add the role you would like to install, you can find exemple in FULL_PLAYBOOK.md
 - Save push modification on your repository ```git add . &&  git commit -a && git push origin master```

## Lunching the script !
Now you are ready to lunch the script, to do so, SSH throught your Ideascube box. 
 - ```ssh root@192.168.1.xxx```
 - Download the bash script ```wget https://github.com/ideascube/ansiblecube/raw/master/oneClickDeploy.sh```
 - Modify right ```chmod +x oneClickDeploy.sh```
 - Lunch the script ```./oneClickDeploy.sh sync kb_mooc_cog Africa/Kinsasha False```
This script takes 4 arguments : 
 - ```sync``` or ```nosync``` which tell to send or not Ideascube name, UUID, installed software over the central server 
 - ```kb_mooc_cog``` is the name of the Ideascube project, this name MUST be the same as the ideascube name stored in ```conf/```
 - ```Africa/Kinsasha``` is the time zone (available in /usr/share/zoneinfo/) to set to the server 
 - ```False``` or ```True``` to tell AnsibleCube to download or not data from Internet (Works so far with all the kiwix project, see exemple in playbook)

## Keep your system up to date ! 
Now you have an ideascube system ready to work, great !
The second part of this doc is going to show you how you can keep up to date your system where ever this one is.

You created just above a file called ```update_NAME_OF_IDEASCUBE_PROJECT.yml```, this one will be called by an Ideascube box each time the system will get an IP address.

Ansible will be executed in Pull mode and It will be called by Network-Manager each time an network interface goes up, the script is stored under ```/etc/NetworkManager/dispatcher.d/ansiblePullUpdate```, it works for eth0 and wlan1
```/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git -C ideasbox update_NAME_OF_IDEASCUBE_PROJECT.yml```

In this exemple you understand quickly that everything will have to be configured in the ```update_NAME_OF_IDEASCUBE_PROJECT.yml```

To do so, you'll have to add and remove roles, for exemple, the role ```logs``` has been written to send logs from the Ideascube box to the central server each time the device gets Internet. 

If you want to lunch a particular update, you'll have to create or adapt an Ansible role. Look at the one already build in the folder ```upgradeKb```