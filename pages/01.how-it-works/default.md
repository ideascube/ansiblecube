---
title: 'Learn how AnsibleCube works'
---

_AnsibleCube is a set of instructions ([source code](https://github.com/ideascube/ansiblecube/tree/oneUpdateFile)), it aim to automatically deploy the [Ideascube plateform](http://github.com/ideascube/ideascube/) and download several types of content \([Kiwix content](http://www.kiwix.org/), [Khan Academy videos](https://fr.khanacademy.org/), [Library Without Border currated content](http://catalog.ideascube.org/omeka.yml.html)\)._

## How ansible works

Ansible has been chosen to pull config file, software and content to the ideascube box which can be an AMD64 server or an ARM server.

Ansible is originally designed to push configuration files from a master to several slaves. But you can use it the other way around where the slaves are able to pull content from a Git server.

## How we use it

In our case the master is this GitHub repository. It contain a playbook with several roles. Each time the ideascube box gets an Internet connection, it synchronizes the distant Git repository with its local Git repository and then gets an update of what must be done on the system. **At this stage your are able to do almost anything!**

### The network configuration

Our network architecture is based on :

* A GitHub repo which holds all the recipes

* A Filer which holds all the heavy files \(so synchronizing the GitRepo is fast)

* A Data server where content from the ideascube box can be automatically pushed towards the server

#### It works for...

So far ansiblecube has been tested only on a ARM Olimex Lime2 A20, Debian Jessie, Kernel 3.4/4.8 and AMD64 server. It should work on any Jessie distribution, probably on Ubuntu and Raspberry Pi.

## Deployment

### What does Ansible do?

**This playbook installs :**

* [ideascube software](http://github.com/ideascube/ideascube/). It can be installed simply with the [apt tool from Debian](http://repos.ideascube.org/debian/jessie). However, ansiblecube will take care of all the small tweaks to make it work.

* Kiwix-server to load ZIM files

* Kalite \(Khan Academy Mooc plateform\)

* BSF Campus Mooc plateform

* Import data in Ideascube media-center

* Synchronise Kalite videos

**It will setup :**

* dnsmasq \(to resolv local domain\)

* hostapd \(to setup the local wifi hotspot\)

* nginx \(to serve http content\)

* uwsgi \(to manage python scripts\)

* Network-Manager

* All system tweaks


