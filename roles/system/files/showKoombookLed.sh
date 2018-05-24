#!/bin/bash

# Use to find a KoomBook among others
echo "Look at your KoomBook, press [CTRL+C] when you found it !"

# Set the LED on
echo default-on >/sys/class/leds/a20-olinuxino-lime2:green:usr/trigger

while :
do
        echo 0 >/sys/class/leds/a20-olinuxino-lime2:green:usr/brightness
        sleep 0.05
        echo 1 >/sys/class/leds/a20-olinuxino-lime2:green:usr/brightness
        sleep 0.5

        # Set heartbeat mode on exit
        trap 'echo heartbeat >/sys/class/leds/a20-olinuxino-lime2:green:usr/trigger; exit;' INT
done
