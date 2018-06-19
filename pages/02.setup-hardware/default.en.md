---
title: 'Set-Up Your Hardware'
---

## ARM Processor: Single Board Computer (SBC)

### Get the Operating System

#### Olimex Lime2

We fully support Olimex Lime2 SBC. KoomBook image is based on [Armbian](https://www.armbian.com/) distribution.

* Download the [latest image](http://filer.bsf-intranet.org/KoomBook_DIY_5.41_Lime2_Debian_jessie_next_4.14.21.7z) built by Libraries Without Borders for Olimex Lime2 board

#### Raspberry Pi 2/3
We support Raspbery Pi 2/3 but we don't provide a pre-made image.  You'll have to use our build script

* Download a new [Raspbian image](https://www.raspberrypi.org/downloads/raspbian/)

#### External Hard Drive

>>>>> AnsibleCube is able to mount an external hard drive to store large amounts of data. The hard drive has to be connected during the first boot and is accessible here `/dev/sda1`. This block device will be mounted and used to store the data.

>>>>> Olimex boards are designed to host a SATA controller, so you can directly connect a SATA hard drive to the board.

>>>> **WATCH OUT: The external hard drive will be automatically FORMATTED without any notice**

### Unzip & Burn

* Use a [good and reliable](https://docs.armbian.com/User-Guide_Getting-Started/#how-to-prepare-a-sd-card) micro SD Card \(class 10!\)
* Download [Etcher](https://etcher.io/), select image and destination, click **Flash!**

### Boot the Board!

#### Olimex

1. Connect the board to a power source (5 V / 2 A)
2. Connect an Ethernet cable (make sure the green and orange LED light stays off)
3. Insert the micro SD card in the slot
4. Push the power switch twice to start the board (the board won't start by itself once connected to a power source)
5. Login through SSH with 
   1. `ssh root@koombook.local`
   2. login: `root` 
   3. password: `123`

#### Raspberry Pi

1. Connect the board to a power source (5 V / 2 A)
2. Connect an Ethernet cable
3. Insert the micro SD card in the slot
4. Login through SSH with 
   1. `ssh pi@raspberrypi.local`
   2. login: `pi`
   3. password: `raspberry`

> > > >>  Enable SSH to connect to the Rapsberry Pi remotely

1. [Use this guide](https://www.raspberrypi.org/documentation/remote-access/ssh/) if you are directly connected to the Raspi
2. Or drop an empty `ssh` file in `/boot/` on your micro SD card

## AMD64 Processor

* Download the [latest Debian jessie](http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-8.5.0-amd64-lxde-desktop.iso), with or without graphical interface.
* Set up your server as you would do for any server you own.
* When asked, create a root user and an IdeasCube user.

Note: you could also use [preseedcube](https://github.com/ideascube/preseedcube) to automate this Debian installation.


