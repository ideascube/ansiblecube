# AnsibleCube
_The aims of this project is to automatically install and configure a device using the [Ideascube plateform](http://github.com/ideascube/ideascube/)._

## How ansible works
Ansible has been chosen to push and pull content, file config and software from and to the ideascube box which can be an AMD64 server or an ARM server.

Ansible is originally design to push content (from a master) to several slaves. But you can use it the other way around where the slaves are able to pull content from a master. 

## How we use it 
In our case the master is the GitHub repository. This repository contain a playbook with different roles. Each time the ideascube box get an Internet connection, it synchronize the distant Git repository with his local Git repository and tough get an update of what must be done on the system. At this stage your are able to do almost anything !

### The network configuration
Our network architecture is based on 
 - A GitHub repo which hold all the recipe 
 - A Filer which hold all the heavy files (so synchronizing the GitRepo is fast)
 - A Data server where content from the ideascube box can be automatically pushed towards the server

#### It works for...
So far ansiblecube has been tested only on a ARM Olimex Lime2 A20, Debian Jessie, Kernel 3.4/4.6 and AMD64 server.
It should work on any Jessie distribution, probably on Ubuntu and Raspberry Pi.

## First to do !

This deployment method install the [ideascube software](http://github.com/ideascube/ideascube/). It can be installed simply with the apt tool from Debian, the repository is located here : http://repos.ideascube.org/debian/jessie/
However, ansiblecube take care of all the small tweak to make it work.

If you need to adapt some settings for your own project, you'll have to create a new configuration file within [this directory](https://github.com/ideascube/ideascube/tree/master/ideascube/conf). 

Please have a look at others configurations files to see how it has been done. When you know what to do, simply send us a pull request with your new file. 

## On your computer, clone AnsibleCube
### Method 1 : Fork and clone 
 - Fork the repository and clone it on your computer to be able to update roles 
 - Open the bash script ```oneClickDeploy.sh``` and change the github repository for the one you own
 - Edit the file ```roles/set_custom_fact/files/device_list.fact```
 - Add a new JSON section to describe what must be installed on your device. **This is JSON syntax, comma and quote a really important !** ```
   - **kb-gin-conakry** is the name of your device
   - **kalite** is the name of the role played but also the name of the application we want to install
   - **activated** Whether we want install or not the application. If True, the application will be installed and configured on the target device. If leaved True, the target device will be updated continuously at each time the later will be connected on Internet
   - **version** For some application it is better to lock the version number instead of installing always the last version. A new version has always to be tested before deployment.
   - **language** You can specify the language you wish to use (must be on 2 letters)
   ```
 	"kb-bsfcampus-sen": {
		"bsfcampus": {
			"activated": "True",
			"version": "100816"
		},
		"kalite": {
			"activated": "True",
			"version": "0.16.8",
			"language": ["fr"]
		},
		"idc_import": {
			"activated": "True",
			"content_name": ["2-Contenus/Logiciel-libre/app.csv","21-BSFCAMPUS/KB_Liste_contenus_bsf_campus.csv"]
		},
		"zim_install": {
			"activated": "True",
			"name": "ubuntudoc.fr tedxlausanne2014.fr tedxlausanne2013.fr tedxlausanne2012.fr tedxgeneva2014.fr  cest-pas-sorcier.fr gutenberg.fr vikidia.fr wikisource.en wikisource.fr wikipedia.fr wikipedia.wo wikipedia.en "
		}
	},
	```
 - Save, commit and push modification to your repository ```git add . &&  git commit -a && git push origin master```
 At this stage you have a new configuration file. This file is going to lunch several roles that are going to be processed on your device

### Method 2 : Send me a pull request
From the github web interface you can also edit ```roles/set_custom_fact/files/device_list.fact``` add your device  and send me a pull request.

## Set up your hardware 
### Case 1 : ARM Proc
If you own an Olimex Lime 2 or Raspberry Pi 2/3, the best is to give a try to Ansible ! 
 - Download an [Armbian image](http://www.armbian.com/olimex-lime-2/) (Choose "Legacy" / "Jessie") for Olimex or a [Raspbian image](https://www.raspberrypi.org/downloads/raspbian/) for Raspberry Pi. You can also use the [last Image](http://filer.bsf-intranet.org/Armbian_5.17_Lime2_Debian_jessie_4.6.3.patch.raw) built by Library without borders
 - Unzip image and burn it on an SD Card (class 10!)
   - **Linux** : ```sudo dd bs=1M if=filename.raw of=/dev/sdx && sync```
   - **Windows** : Use [Rufus](https://rufus.akeo.ie/) and fellow the instructions 
 - Insert SD card on the board, first start is longer (update, SSH keys init, etc.)
 - Connect an Ethernet cable. Keyboard and screen if you can not login with SSH
 - Login through SSH : Default password is `password` for Armbian and pi / raspberry for Raspberry

> AnsibleCube is able to mount an external hard drive to store large amount of data. The hard drive has to be connected from firstboot and accessible here `/dev/sda1`. This block will be mounted at custom run and used to store the data

### Case 2 : AMD64
 - [Download the last Debian jessie](http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-8.5.0-amd64-lxde-desktop.iso), with or without graphical interface : 
 - Set up your server as you will do for any server you own
 - When asked, create a root user and an ideascube user (ideascube user password will be automatically overrided during ansible deployment)

## Prepare the deployment !
### Download oneClickDeploy script
Now you are ready to start deployment on the targeted device
#### With SSH
 - ```ssh ideascube@192.168.1.xxx```
 - Login with SSH : Login : `root`, default password is 1234 for Armbian and pi / raspberry for Raspberry 
 - Download the bash script : ```wget https://github.com/ideascube/ansiblecube/raw/oneUpdateFile/oneClickDeploy.sh --no-check-certificate```
 - Modify rights ```chmod +x oneClickDeploy.sh```
 
#### On the device directly
 - Plug a keyboard on your device
 - Login : `root`, default password is 1234 for Armbian and pi / raspberry for Raspberry 
 - If needed, type this command to change the mapping of your keyboard `loadkeys fr`
 - Download the bash script : ```wget https://github.com/ideascube/ansiblecube/raw/oneUpdateFile/oneClickDeploy.sh --no-check-certificate```
 - Modify rights ```chmod +x oneClickDeploy.sh```

#### Set the right settings
This script takes 4 arguments : 
 - ```script_action``` : ```master``` et/ou ```custom``` Master run must be done for a brand new machine (ex: Debian fresh install), however the KoomBook Image has been already mastered.
 - ```managed_by_bsf```: ```True``` ou ```False``` This setting send metrics to the central server. You'll need the password server to connect through SSH. If you don't have it, set it to ```False```
 - ```ideascube_project_name``` : ex ```kb_mooc_cog``` is the name of the Ideascube project, this name MUST be the same as the ideascube name stored in ```ideascube/conf/``` ideascube github repository
 - ```timezone``` : ex ```Africa/Kinsasha``` is the time zone (available in /usr/share/zoneinfo/) to set to the server or check at https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
 
**WARNING** : If you are running this command behind a firewall, be sure the NTP protocol is open for outgoing connection, if not, set manually the date on your system : `date -s 20160513`

### Lunch the deployment 
/!\ KoomBook image don't need master run
  1. Create a master : ```./oneClickDeploy.sh script_action=master```
  2. Customize the master : ```./oneClickDeploy.sh script_action=custom managed_by_bsf=True ideascube_project_name=kb_mooc_cog timezone=Europe/Paris```
  3. Both at the same time : ```./oneClickDeploy.sh script_action=master,custom managed_by_bsf=True ideascube_project_name=kb_mooc_cog timezone=Europe/Paris```

## Keep your system up to date ! 
Now you have an ideascube system ready to work, great !

Ansible will be executed in Pull mode and this file will be called by Network-Manager each time a network interface goes up, the script is stored under `/etc/NetworkManager/dispatcher.d/ansiblePullUpdate`, it works for eth0 and wlan1
exemple of ```ansiblePullUpdate``` : ```/usr/local/bin/ansible-pull -s 120 -d /var/lib/ansible/local -C oneUpdateFile -i hosts -U https://github.com/ideascube/ansiblecube.git main.yml --tags "update"```

From now on, everything depend from the file ```roles/set_custom_fact/files/device_list.fact```. If you left some application with ```"activated": "True",``` those ones will be updated each time the device will be connected to Internet.

## Available TAGS
- idc_import : Call the ideascube import medias command with the right file given with 
```
		"idc_import": {
			"activated": "True",
			"content_name": ["2-Contenus/Logiciel-libre/app.csv","21-BSFCAMPUS/KB_Liste_contenus_bsf_campus.csv"]
		},
```

## Rename a device
You may eventually want to rename a device. This can be done with oneClickDeploy.sh this way : 
```
./oneClickDeploy.sh script_action=rename ideascube_project_name=new_name timezone=Africa/Dakar
```
