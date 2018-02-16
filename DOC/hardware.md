# Set up your hardware

## Case 1: ARM processor

If you own an Olimex Lime 2 or Raspberry Pi 2\/3, the best is to give AnsibleCube a try!

> AnsibleCube is able to mount an external hard drive to store large amount of data. The hard drive has to be connected from first boot and accessible here `/dev/sda1`. This block device will be mounted and used to store the data.
> Olimex boards are designed to host a SATA controler, you can directly connect a SATA hard drive to the board.
> The hard drive can be formated using :
>
> `sudo parted /dev/sda mklabel msdos mkpart primary ext4 0% 100% -s`
> `sudo mkfs.ext4 /dev/sda1`

* You can use the [latest image]](http://filer.bsf-intranet.org/KoomBook_DIY_5.37_Lime2_Debian_jessie_next_4.14.8.7z)) built by Libraries Without Borders for Olimex Lime2 board
OR 
* Download an [Armbian image](http://www.armbian.com/olimex-lime-2/) \(Choose "Vanilla" / "Jessie"\) for Olimex or a [Raspbian image](https://www.raspberrypi.org/downloads/raspbian/) for Raspberry Pi.

* Unzip image and burn it on an **micro** SD Card \(class 10!\)

  * **Linux**:

    * Insert your micro SD card

    * type `dmesg` in a terminal and find out what path is used by your micro SD card

    * then `sudo dd bs=1M if=image_file.raw of=/dev/sdX && sync`

  * **Windows**: Use [Rufus](https://rufus.akeo.ie/) and follow the instructions - Insert SD card on the board. Be aware that first start is longer \(updates, SSH keys init, etc.\)

* Insert the micro SD card in your device

* If you don't know the IP address of your device, connect an Ethernet cable, Keyboard and screen

* Login

  * **Armbian :** `root / 1234`

  * **Raspberry :** `pi` / `raspberry`

## Case 2: AMD64 processor

* Download the [latest Debian jessie](http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-8.5.0-amd64-lxde-desktop.iso), with or without graphical interface.

* Set up your server as you would do for any server you own.

* When asked, create a root user and an ideascube user.

Note: you could also use [preseedcube](https://github.com/ideascube/preseedcube) to automate this Debian installation.

