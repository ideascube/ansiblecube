---
title: 'Deploy AnsibleCube with BuildMyCube'
---

## Download buildMyCube.sh

Your device is now ready to be configured with AnsibleCube, let's do it !

### Through SSH

* `ssh ideascube@device_ip_address`

  * **Armbian:** `root / 1234`

  * **Raspberry:** `pi` / `raspberry`

* Download the bash script: `wget https://github.com/ideascube/ansiblecube/raw/oneUpdateFile/buildMyCube.sh`

* Modify rights: `chmod +x buildMyCube.sh`

### From your device

* Plug a keyboard on your device

* Connect to the device with

  * **Armbian:** `root / 1234`

  * **Raspberry:** `pi` / `raspberry`

* If needed, type this command to change the mapping of your keyboard: `loadkeys fr`

* Download the bash script: `wget https://github.com/ideascube/ansiblecube/raw/oneUpdateFile/buildMyCube.sh`

* Modify rights: `chmod +x buildMyCube.sh`

**WARNING**: If you are running this command behind a firewall, be sure the NTP protocol is allowed for outgoing connections. If not, manually set the date on your system: `date -s 20160513`

## Execute buildMyCube.sh

buildMyCube is a wrapper around the ansible-pull command line tool.

ansible-pull needs some parameters to run **AnsibleCube** correctly. This script will build the right command line for you.

At Libraries Without Borders we use two important files:

1. [Ideascube configuration file](https://github.com/ideascube/ideascube/tree/master/ideascube/conf "Fichier de configuration Ideascube") on Ideascube github repository

2. [Device configuration file](https://github.com/ideascube/ansiblecube/blob/oneUpdateFile/roles/set_custom_fact/files/device_list.fact) on Ansiblecube github repository

Thoses files helps us to automate deployment. If you would like to use one of our templates, go for it, dig in those files, find the configuration you like, and pass the arguments to `buildMyCube.sh`. Otherwise, feel free to give the name you want to your device and the script will ask a few questions about the configuration you would like to have!

### Script help

```

⇒ sudo ./buildMyCube.sh

 [+] Build My Cube [+]

 Usage:

 ./buildMyCube.sh -n device_name [-t|--timezone] [-m|--managment] [-h|--hostname] [-a|--action] [-b|--branch]

 Arguments :

 -n|--name Name of your device.

           An Ideascube configuration template can be choosen from the links below :

             + https://github.com/ideascube/ansiblecube/blob/oneUpdateFile/roles/set_custom_fact/files/device_list.fact

             + https://github.com/ideascube/ideascube/tree/master/ideascube/conf Ex: -n kb_mooc_cog

 -t|--timezone  The timezone.

                Default : Europe/Paris

                Ex: -t Africa/Dakar

 -b|--branch    Set Github branch you'd like to use

                Default : oneUpdateFile

 -m|--managment Install BSF tools, set to false if not from BSF

                Default : True

                Ex: -m true|false

 -h|--hostname  Set the server hostname

                Default : Equal to -n

                Ex: -h my_hostname.lan


-w|--wifi-pwd   Override the default AP wifi password
                Ex: -w 12ET4690

 -a|--action    Type of action : master / custom / rename / update / package_management / idc_import / kalite_import

                Default : master,custom

                Ex: -a rename

     - master : Install Ideascube and Kiwix server with strict minimal configuration Nginx, Network-manager, Hostapd, DnsMasq, Iptables rules

     - custom : This action will use the -n and -t parameter to configure your device. It will also install and configure third party application such as Kalite, Media-center content, Zim files

     - rename : Rename a device (-n and -t parameter can be redefined) - update : Run a full update on the device (same will be done at each Internet connection)

     - package_management : Special command that will only run the download/installation of zim files

     - idc_import : Special command that will only mass import media in the media-center

     - kalite_import : Special command that will only import content for Kalite

 Few examples :

 [+] Create a master based on kb_bdi_irc Ideascube template

     ./buildMyCube.sh -n kb_bdi_irc -a master

 [+] Full install with personnal settings (no need of -a parameter)

     ./buildMyCube.sh -n my_box -t Africa/Dakar -m false

 [+] Rename a device

     ./buildMyCube.sh -n kb_bdi_irc -t Europe/Paris -a rename

```

## Arguments one by one

### --name

This is the only mandatory argument. It will be used to set your server name, wifi hotspot name, dns name, ideascube name.

If the latter matches with one found in the [AnsibleCube device configuration file](https://github.com/ideascube/ansiblecube/blob/oneUpdateFile/roles/set_custom_fact/files/device_list.fact) the configuration template will be used. Otherwise a dialog box will pop up to ask you some questions about 3rd party softwares \(Khan Academy, Zim files\) you would like to install and configure.

### --timezone

By default the timezone is `Europe/Paris`. This option is useful if your headquarter is somewhere else. Timezone can be found on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

### --branch

This is meant for testing only. In most case you won't have to use this argument.

### --managment

By default this argument is set to `True`, meaning that the device installed will be managed remotely by Libraries Whitout Borders. If your device is used for a personal project, set this argument to `False`.

### --hostname

By default, the hostname will be taken from `--name` argument. If you want to have a specific name and a specific hostame, set this variable. Don't forget to add **`.lan`**.

### --wifi-pwd

Override the default wifi hotspot password with the given one

### --action

By default this argument is not needed, the default value will be `master,custom`.

* master

This argument matches an AnsibleCube tag. It means that this argument will match specific action. For instance, this argument is usefull to build a minimal configuration \(like a master image for easy duplicating\). Only Ideascube and Kiwix server will be installed and configured. If you are using an ARM CPU you will get to the homepage by typing `http://koombook.lan`. Using `http://ideasbox.lan` for an AMD64 processor.

This is great to give a try, but not enough for a long term use.

* custom

This "tag" will match more actions within AnsibleCube, like configuration of your hotspot name, dns name matching the `--name`. It will also install and configure 3rd party applications.

* rename

This action can be used in case you have fully installed a device \(master and custom action\) and you are not happy with the device name, then use the rename tag to change it. Examples following.

> **WARNING**

> This action can't be used if the **master** and **custom** action have not been executed.

* update

This action will keep your device up to date every time the device gets an Internet connection. This is done automatically. However you can use it manually with this script.

> **WARNING**

> This action can't be used if the **master** and **custom** action have not been executed.

* zim\_install

This will trigger the task of downloading and installing Zim files from Internet. Be carefull, you will need a fast Internet connection as the ZIM files are pretty heavy \(from 200Mo to 60Go\).

> **WARNING**

> This action can't be used if the **master** and **custom** action have not been executed.

* idc\_import

This will trigger the task of massively importing content within the Ideascube media-center.

Before importing, you will need to build a csv file and gather all you medias in one folder. The best is to ask for help on \#ideascube on irc.freenode.org.

> **WARNING**

> This action can't be used if the **master** and **custom** action have not been executed.

* kalite\_import

For faster installation and configuration, we have been mirroring all the kalite videos. Unfortunaltery, this mirror cannot be used if you are standing outside of Libraries Without Borders office. You will have to download manually the videos from the Kalite web interface.

> **WARNING**

> This action can't be used if the **master** and **custom** action have not been executed.

## Launch the deployment

### Examples

##### Create a master based on kb\_bdi\_irc Ideascube template

`./buildMyCube.sh -n kb_bdi_irc -a master`

##### Create a master based on kb\_bdi\_irc Ideascube template with specific hostname

`./buildMyCube.sh -n kb_bdi_irc -a master -h box.lan`

##### Full install with personal configuration and without management

`./buildMyCube.sh -n my_box -t Africa/Dakar -m false`

##### Full install with personal configuration, without management and custom hostname

`./buildMyCube.sh -n my_box -t Africa/Dakar -m false -h foo.lan`

##### Rename a device

`./buildMyCube.sh -n kb_bdi_irc -t Europe/Paris -a rename`

##### Update manually the device

`./buildMyCube.sh -a update`

> You can follow the installation with `tail -f /var/log/ansible-pull.log`

## Connect to your device

Once `buildMyCube.sh` is done installing, reboot your newly configured device and look for an new wifi hotspot on your laptop.

## Keep your system up to date!

Now you have an ideascube system ready to work, great!

Ansible will be executed in Pull mode. The following file will be called by Network-Manager every time a network interface goes up: `/etc/NetworkManager/dispatcher.d/ansiblePullUpdate`

Example of `ansiblePullUpdate` file : `/usr/local/bin/ansible-pull -s 120 -d /var/lib/ansible/local -C oneUpdateFile -i hosts -U https://github.com/ideascube/ansiblecube.git main.yml --tags update`

The file `roles/set_custom_fact/files/device_list.fact` is used to know what actions have to be done on the device.

If the latter have `actived: True`, the following action will be executed each time the device get an Internet connection.


