# Set up your hardware

## ARM processor : Single Board Computer (SBC)

### Olimex Lime2
We fully support Olimex Lime2 SBC. KoomBook image is based on [Armbian](https://www.armbian.com/) distribution.

1. Download the [latest image](http://filer.bsf-intranet.org/KoomBook_DIY_5.41_Lime2_Debian_jessie_next_4.14.21.7z) built by Libraries Without Borders for Olimex Lime2 board

Login infos : `root` / `1234`

### Raspberry Pi 2\/3
We support Raspbery Pi 2/3 but we don't provide a pre-made image, you'll have to use our build script

1. Download a fresh [Raspbian image](https://www.raspberrypi.org/downloads/raspbian/) and enable SSH

Login infos : `pi` / `raspberry`

### External hard drive
> AnsibleCube is able to mount an external hard drive to store large amount of data. The hard drive has to be connected from first boot and accessible here `/dev/sda1`. This block device will be mounted and used to store the data.
> Olimex boards are designed to host a SATA controller, you can directly connect a SATA hard drive to the board.
> **WATCH OUT : The external hard drive will be automatically FORMATTED without any notice**

### Unzip & Burn

* Use a [good and reliable](https://docs.armbian.com/User-Guide_Getting-Started/#how-to-prepare-a-sd-card) micro SD Card \(class 10!\)
* Download [Etcher](https://etcher.io/), select image and destination, click **Flash!**

### Boot the board !

* Connect the board to good a power source (5v/2A)
* Connect an Ethernet cable (make sure the green and orange led stays off)
* Insert the micro SD card in the slot
* Push 2s the power switch to start the board (the board won't start by itself once connected to a power source)
* Login through SSH to : ssh root@koombook.local / `root / 1234`
  
## AMD64 processor

* Download the [latest Debian jessie](http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-8.5.0-amd64-lxde-desktop.iso), with or without graphical interface.

* Set up your server as you would do for any server you own.

* When asked, create a root user and an ideascube user.

Note: you could also use [preseedcube](https://github.com/ideascube/preseedcube) to automate this Debian installation.


