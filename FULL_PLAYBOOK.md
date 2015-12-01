# Full playbook with exemple 

```
---
#Switch over "localhost" or "SystemPushInstall"

# localhost is used when ansible-pull is used to play the playbook
# SystemPushInstall is used in PUSH mode and you have to set the device's IP in "hosts" file 

- hosts: localhost
# - hosts: SystemPushInstall

  roles:
    # Enable or disable to suit your needs
    - systemInit
    - nginx
    - dnsmasq
    - hostapd
    - iptables
    - uwsgi
    - kalite

    # Install ideascube in version 0.5.0
    - role: ideascube
      version: "0.5.0-1"

    # You can play a role for a specific device 
    # Installa App Inventor but only if the hostname match the KoomBook kb_mooc_vog_345
    - appinventor
        when: ansible_hostname == 'kb_mooc_vog_345'

    # Install MongoDB and BSF Campus or KoomBook EDU plate-forme on the KoomBook
    - mongodb

    - role: mook, 
      mook_name: bsfcampus

    - role: mook, 
      mook_name: koombookedu

    # Install and configure a kiwix project, look at portProject which define the listenning port. 
    # you can specify in version a various number of zim to download during install, refere here to have the 
    # correct name : http://download.kiwix.org/zim

    - role: kiwix
      kiwixProject: wikipedia
      portProject: 8002
      version: ['wikipedia_tum_all_nopic_2015-10.zim','wikipedia_tum_all_nopic_2015-09.zim']

    - role: kiwix
      kiwixProject: wikisource
      portProject: 8003
      version: "wikipedia_fr_all_2015-11.zim"

    - role: kiwix
      kiwixProject: vikidia
      portProject: 8004
      version: ""

    - role: kiwix
      kiwixProject: cpassorcier
      portProject: 8005
      version: ""

    - role: kiwix
      kiwixProject: ubuntudoc
      portProject: 8006
      version: ""

    - role: kiwix
      kiwixProject: gutenberg
      portProject: 8007
      version: "gutenberg_fr_all_10_2014.zim"

    - role: kiwix
      kiwixProject: universcience
      portProject: 8009
      version: ""

    - role: kiwix
      kiwixProject: ted
      portProject: 8010
      version: ""

    - role: kiwix
      kiwixProject: software
      portProject: 8011
      version: ""
```