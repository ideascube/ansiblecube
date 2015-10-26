# Ansible-KoomBook
Ansible has been choose to push and pull content, file config and softawre from and to the KoomBook.

Ansible is originaly design to push content (from a master) to several slaves. But you can use it the other way around where the slaves are able to pull content from a master. 

In our case the master is the GitHub repository. This repo contain all the recipes. Each time the KoomBook get an Internet connection, the latter synchronise the distant Git repo with his local Git repo and tough get an update of what must be done on the system. At this stage your are able to do allmost anything !

Our network architecture is based on 
 - A GitHub repo which hold all the recipe 
 - A Filer which hold all the heavy files (so synchronising the GitRepo is fast)
 - A Data server where content from the KoomBook can be automaticly pushed towards the server

 All connections has been switched over port 443 to ensure connection even behind a firewall.

So far Ansible-KoomBook has been tested only on Olimex Lime2 A20, Debian Jessie, Kernel 3.4, however it should work on any Jessie distrib, probalby on Ubuntu and Raspberry Pi.

The repo is just stable enough to work on Olimex but all the recipe should be improved to be more flexible.

## Create a master 
If you own an Olimex, the best is to give a try to Ansible ! 
 - Download image from this file http://mirror.igorpecovnik.com/Armbian_4.3_Lime2_Debian_jessie_3.4.108.zip or visit to choose the one you like http://www.armbian.com/download/
 - Unzip image and burn it on an SD Card (class 10!)
 - ```dd bs=1M if=filename.raw of=/dev/sdx```
 - Insert SD card on the board, first start is longer (update, SSH keys init)
 - Default password is 1234

## Install Ansible and use recipe
 - Best way to install Ansible is from pip (you'll get the most up to date version)
```pip install ansible```

- Clone the Git repo somewhere on your computer 
```git clone https://github.com/fheslouin/ansible-koombook.git```
- then 
```cd ansible-koombook```

- Now you have to modify the ```hosts``` file in order to match to your respective slaves (one machine per line).
In this case all the machines below ```[koombook]``` will be updated

- Now you need to copy your public SSH key over the KoomBook
```ssh-copy-id root@192.168.1.4```

At this stage, you have Ansible installed and ready, you cloned the Git repo, you wrote the hosts file to designate the slaves and your machine (master) is able to connect automaticly to the KoomBook throught SSH with your public key.

## First initialisation 
The first initialisation called with the role ```systemInit``` has been written to get an update system, with most essential package and basic config. It also patch the U-Boot Olimex A20 to disable some ennoying default beahaviour. 