#!/bin/bash
if [ -f /media/hdd/mongodb/mongod.lock ]; then
	rm /media/hdd/mongodb/mongod.lock 
	/usr/bin/mongod --dbpath=/media/hdd/mongodb --repair
	chown -R mongodb:nogroup /media/hdd/mongodb
	chown -R mongodb:nogroup /var/log/mongodb
fi