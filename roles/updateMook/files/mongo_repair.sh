#!/bin/bash
if [ -f /media/hdd/mongodb/mongod.lock ]; then rm /media/hdd/mongodb/mongod.lock && /usr/bin/mongod --dbpath=/media/hdd/mongodb --repair; fi