---
title: 'About AnsibleCube'
---

_AnsibleCube is a set of instructions ([source code](https://github.com/ideascube/ansiblecube/tree/oneUpdateFile)), that automatically deploys the [IdeasCube platform](http://github.com/ideascube/ideascube/) and downloads several types of content \([Kiwix content](http://www.kiwix.org/), [Khan Academy videos](https://fr.khanacademy.org/), [Libraries Without Borders curated content](http://catalog.ideascube.org/omeka.yml.html)\)._

## How Ansible Works

Ansible pulls configuration files, software and content to the IdeasCube server (either an AMD64 server or an ARM server).

It was originally designed to push configuration files from a primary server to several replicas. But you can also use it the other way around where the replicas can pull content from a Git server.

## How We Use It

In our case, the master is the GitHub repository, which contains a playbook with several roles. Each time the IdeasCube Box gets an Internet connection, it synchronizes the distant Git repository with its local Git repository and updates its system.  **At this stage you can do almost anything!**

### Network Configuration

Our network architecture is based on:

* A GitHub repo which holds all the recipes

* A Filer which holds all the heavy files to allow fast synchronization of the GitRepo

* A Data Server where content from the IdeasCube Box can be automatically pushed towards the server

#### Supported Platforms

So far, AnsibleCube has only been tested ARM Olimex Lime2 A20, Debian Jessie, Kernel 3.4/4.8 and AMD64 server. It should work on any Jessie distribution, and probably on Ubuntu and Raspberry Pi.

## Deployment

### What does Ansible do?

**This playbook installs:**
* [IdeasCube software](http://github.com/ideascube/ideascube/). It can be installed simply with the [APT tool from Debian](http://repos.ideascube.org/debian/jessie). AnsibleCube will take care of all the small tweaks to make it work.
* Kiwix-server to load ZIM files
* Kalite \(Khan Academy Mooc plateform\)
* BSF Campus Mooc platform
* Import data in IdeasCube media-center
* Synchronise Kalite videos

**It will setup :**
* dnsmasq \(to resolv local domain\)
* hostapd \(to setup the local wifi hotspot\)
* nginx \(to serve http content\)
* uwsgi \(to manage python scripts\)
* Network-Manager
* All system tweaks