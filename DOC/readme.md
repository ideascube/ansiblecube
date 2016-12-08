# AnsibleCube

_AnsibleCube aim to automatically deploy the [Ideascube plateform](http://github.com/ideascube/ideascube/) and download several types of content \(ZIM files, Khan Academy videos, Ideascube packages\)._

## How ansible works

Ansible has been chosen to pull config file, software and content to the ideascube box which can be an AMD64 server or an ARM server.

Ansible is originally design to push configuration files from a master to several slaves. But you can use it the other way around where the slaves are able to pull content from a Git server.

## How we use it

In our case the master is this GitHub repository. It contain a playbook with several roles. Each time the ideascube box get an Internet connection, it synchronize the distant Git repository with his local Git repository and tough get an update of what must be done on the system. **At this stage your are able to do almost anything!**

### The network configuration

Our network architecture is based on :

* A GitHub repo which hold all the recipe 

* A Filer which hold all the heavy files \(so synchronizing the GitRepo is fast) 

* A Data server where content from the ideascube box can be automatically pushed towards the server

#### It works for...

So far ansiblecube has been tested only on a ARM Olimex Lime2 A20, Debian Jessie, Kernel 3.4\/4.8 and AMD64 server.It should work on any Jessie distribution, probably on Ubuntu and Raspberry Pi.

## Deployment

### What does Ansible ?

This playbook install :

* [ideascube software](http://github.com/ideascube/ideascube/). It can be installed simply with the [apt tool from Debian](http://repos.ideascube.org/debian/jessie). However, ansiblecube take care of all the small tweak to make it work.

* Kiwix-server to load ZIM files

* Kalite \(Khan Academy Mooc plateform\)

* BSF Campus Mooc plateform

* Import data in Ideascube media-center

* Synchronise Kalite videos

It setup :

* Dnsmasq \(to resolv local domain\)

* Hostapd \(to setup the local wifi hotspot\)

* Nginx \(to server http content\)

* Uwsgi \(to manage python script\)

* Network-manager

* All system tweak

