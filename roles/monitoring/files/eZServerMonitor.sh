#!/bin/bash

# **************************************************** #
#                                                      #
#                eZ Server Monitor `sh                 #
#                                                      #
#             ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤              #
#                                                      #
#     @name eZ Server Monitor `sh                      #
#     @author ShevAbam                                 #
#     @website ezservermonitor.com                     #
#     @created 2014-06-17                              #
#     @version 2.1                                     #
#                                                      #
# **************************************************** #


# ************************************************************ #
# *                        [ CONFIG ]                        * #
# ************************************************************ #
FILE="dataBattery.csv"

# *************************************************************** #
# *                        [ FUNCTIONS ]                        * #
# *************************************************************** #

# Function : system
function system()
{
    UPTIME=`cat /proc/uptime`
    UPTIME=${UPTIME%%.*}
    UPTIME_MINUTES=$(( UPTIME / 60 % 60 ))
    UPTIME_HOURS=$(( UPTIME / 60 / 60 % 24 ))
    UPTIME_DAYS=$(( UPTIME / 60 / 60 / 24 ))

    LAST_BOOT_DATE=`who -b | awk '{print $3}'`
    LAST_BOOT_TIME=`who -b | awk '{print $4}'`

    CURRENT_DATE=`/bin/date '+%F %T'`
    CURRENT_TIME=`/bin/date '+%T'`
    
	echo -n "$CURRENT_DATE;$LAST_BOOT_DATE;$LAST_BOOT_TIME;$UPTIME_DAYS;$UPTIME_HOURS;$UPTIME_MINUTES;" >> $FILE
}

# Function : load average
function load_average()
{
    PROCESS_NB=`ps -e h | wc -l`
    PROCESS_RUN=`ps r h | wc -l`

    CPU_NB=`cat /proc/cpuinfo | grep "^processor" | wc -l`

    LOAD_1=`cat /proc/loadavg | awk '{print $1}'`
    # LOAD_1_PERCENT=`echo $LOAD_1 | awk '{print 100 * $1}'`
    LOAD_1_PERCENT=`echo $(($(echo $LOAD_1 | awk '{print 100 * $1}') / $CPU_NB))`
    if [ $LOAD_1_PERCENT -ge 100 ] ; then
        LOAD_1_PERCENT=100;
    fi

    if [ $LOAD_1_PERCENT -ge 75 ] ; then
        LOAD_1_COLOR=${RED}
    elif [ $LOAD_1_PERCENT -ge 50 ] ; then
        LOAD_1_COLOR=${YELLOW}
    else
        LOAD_1_COLOR=${WHITE}
    fi

    LOAD_2=`cat /proc/loadavg | awk '{print $2}'`
    # LOAD_2_PERCENT=`echo $LOAD_2 | awk '{print 100 * $1}'`
    LOAD_2_PERCENT=`echo $(($(echo $LOAD_2 | awk '{print 100 * $1}') / $CPU_NB))`
    if [ $LOAD_2_PERCENT -ge 100 ] ; then
        LOAD_2_PERCENT=100;
    fi

    if [ $LOAD_2_PERCENT -ge 75 ] ; then
        LOAD_2_COLOR=${RED}
    elif [ $LOAD_2_PERCENT -ge 50 ] ; then
        LOAD_2_COLOR=${YELLOW}
    else
        LOAD_2_COLOR=${WHITE}
    fi

    LOAD_3=`cat /proc/loadavg | awk '{print $3}'`
    # LOAD_3_PERCENT=`echo $LOAD_3 | awk '{print 100 * $1}'`
    LOAD_3_PERCENT=`echo $(($(echo $LOAD_3 | awk '{print 100 * $1}') / $CPU_NB))`
    if [ $LOAD_3_PERCENT -ge 100 ] ; then
        LOAD_3_PERCENT=100;
    fi

    if [ $LOAD_3_PERCENT -ge 75 ] ; then
        LOAD_3_COLOR=${RED}
    elif [ $LOAD_3_PERCENT -ge 50 ] ; then
        LOAD_3_COLOR=${YELLOW}
    else
        LOAD_3_COLOR=${WHITE}
    fi

    echo -n "$LOAD_1;$LOAD_2;$LOAD_3;" >> $FILE
}

# Function : CPU
function cpu()
{
    CPU_USAGE=`top -b -d1 -n1|grep -i "Cpu(s)"|head -c21|cut -d ' ' -f2|cut -d '%' -f1`

    echo -n "$CPU_USAGE;" >> $FILE
}

# Function : memory
function memory()
{
    MEM_USED=`/usr/bin/free -tmo | grep Mem: | awk '{print $3}'`
    SWAP_USED=`/usr/bin/free -tmo | grep Swap: | awk '{print $3}'`

    echo -n "$MEM_USED;$SWAP_USED;" >> $FILE
}

# Function : battery
function battery()
{
    BAT_STATUS=`cat  /sys/class/power_supply/battery/uevent | grep STATUS |cut -d '=' -f2`
    BAT_PRESENT=`cat  /sys/class/power_supply/battery/uevent | grep PRESENT |cut -d '=' -f2`
    BAT_HEALTH=`cat  /sys/class/power_supply/battery/uevent | grep HEALTH |cut -d '=' -f2`
    BAT_VOLTAGE_NOW=`cat  /sys/class/power_supply/battery/uevent | grep VOLTAGE_NOW |cut -d '=' -f2`
    BAT_CURRENT_NOW=`cat  /sys/class/power_supply/battery/uevent | grep CURRENT_NOW |cut -d '=' -f2`
    BAT_CAPACITY=`cat  /sys/class/power_supply/battery/uevent | grep CAPACITY |cut -d '=' -f2`

    BAT_VOLTAGE_NOW=`echo "$BAT_VOLTAGE_NOW 10000" | awk '{print int( ($1/$2) + 1 )}'`
    BAT_CURRENT_NOW=`echo "$BAT_CURRENT_NOW 10000" | awk '{print int( ($1/$2) + 1 )}'`

    echo "$BAT_STATUS;$BAT_PRESENT;$BAT_HEALTH;$BAT_VOLTAGE_NOW;$BAT_CURRENT_NOW;$BAT_CAPACITY;" >> $FILE
}

# Function : network
function network()
{
    INTERFACES=`/sbin/ifconfig |awk -F '[/  |: ]' '{print $1}' |sed -e '/^$/d'`

    if [ -e "/usr/bin/curl" ] ; then
        IP_WAN=`curl -s ${GET_WAN_IP}`
    else
        IP_WAN=`wget ${GET_WAN_IP} -O - -o /dev/null`
    fi

    echo
    echo -e "${BOLD}${WHITE_ON_GREY}  Network  ${RESET}"

    for INTERFACE in $INTERFACES
    do
        IP_LAN=`/sbin/ip -f inet -o addr show ${INTERFACE} | cut -d\  -f 7 | cut -d/ -f 1`
        echo -e "  ${GREEN}IP LAN (${INTERFACE})\t ${WHITE}$IP_LAN"
    done

    echo -e "  ${GREEN}IP WAN\t ${WHITE}$IP_WAN"
}

# Function : ping
function ping()
{
    echo
    echo -e "${BOLD}${WHITE_ON_GREY}  Ping  ${RESET}"

    for HOST in ${PING_HOSTS[@]}
    do
        PING=`/bin/ping -qc 1 $HOST | awk -F/ '/^rtt/ { print $5 }'`

        echo -e "  ${GREEN}${HOST}\t ${WHITE}$PING ms"
    done
}

# Function : Disk space  (top 5)
function disk_space()
{
    HDD_TOP=`df -h | head -1 | sed s/^/"  "/`
    #HDD_DATA=`df -hl | grep -v "^Filesystem" | grep -v "^Sys. de fich." | sort -k5r | head -5 | sed s/^/"  "/`
    # HDD_DATA=`df -hl | sed "1 d" | grep -v "^Filesystem" | grep -v "^Sys. de fich." | sort | head -5 | sed s/^/"  "/`

    if [ ${DISK_SHOW_TMPFS} = true ] ; then
        HDD_DATA=`df -hl | sed "1 d" | grep -v "^Filesystem|Sys." | sort | head -5 | sed s/^/"  "/`
    else
        HDD_DATA=`df -hl | sed "1 d" | grep -v "^Filesystem|Sys." | grep -vE "^tmpfs|udev|/dev" | sort | head -5 | sed s/^/"  "/`
    fi

    echo
    echo -e "${BOLD}${WHITE_ON_GREY}  Disk space (top 5)  ${RESET}"
    echo -e "${GREEN}$HDD_TOP"
    echo -e "${WHITE}$HDD_DATA"
}

# Function : services
function services()
{
    echo
    echo -e "${BOLD}${WHITE_ON_GREY}  Services  ${RESET}"

    for PORT in "${!SERVICES_NAME[@]}"
    do
        NAME=${SERVICES_NAME[$PORT]}
        HOST=${SERVICES_HOST[$PORT]}

        CHECK=`(exec 3<>/dev/tcp/$HOST/$PORT) &>/dev/null; echo $?`

        if [ $CHECK = 0 ] ; then
            CHECK_LABEL=${WHITE}ONLINE
        else
            CHECK_LABEL=${RED}OFFLINE
        fi

        echo -e "  ${GREEN}$NAME ($PORT) : ${CHECK_LABEL}${RESET}"
    done
}

# Function : hard drive temperatures
function hdd_temperatures()
{
    if [ ${TEMP_ENABLED} = true ] ; then
        echo
        echo -e "${BOLD}${WHITE_ON_GREY}  Hard drive Temperatures  ${RESET}"

        DISKS=`ls /sys/block/ | grep -E -i '^(s|h)d'`
        
        # If hddtemp is installed
        if [ -e "/usr/sbin/hddtemp" ] ; then

            for DISK in $DISKS
            do
                TEMP_DISK=`hddtemp -n /dev/$DISK`"°C"
                
                echo -e "  ${GREEN}/dev/$DISK\t${WHITE}$TEMP_DISK"
            done
        else
            echo -e "${WHITE}\nPlease, install hddtemp${WHITE}"
        fi
    fi
}

# Function : system temperatures
function system_temperatures()
{
    if [ ${TEMP_ENABLED} = true ] ; then
        echo
        echo -e "${BOLD}${WHITE_ON_GREY}  System Temperatures  ${RESET}"

        # If lm-sensors is installed
        if [ -e "/usr/bin/sensors" ] ; then 
            TEMP_CPU=`/usr/bin/sensors | grep "^CPU Temp" | cut -d '+' -f2 | cut -d '.' -f1`"°C"
            TEMP_MB=`/usr/bin/sensors | grep "^Sys Temp" | cut -d '+' -f2 | cut -d '(' -f1`
            
            echo -e "  ${GREEN}CPU          ${WHITE}$TEMP_CPU"
            echo -e "  ${GREEN}Motherboard  ${WHITE}$TEMP_MB"
        else
            echo -e "${WHITE}\nPlease, install lm-sensors${WHITE}"
        fi
    fi
}

function header()
{
	echo "CURRENT_DATE;LAST_BOOT_DATE;LAST_BOOT_TIME;UPTIME_DAYS;UPTIME_HOURS;UPTIME_MINUTES;LOAD_1;LOAD_2;LOAD_3;CPU_USAGE;MEM_USED;SWAP_USED;BAT_STATUS;BAT_PRESENT;BAT_HEALTH;BAT_VOLTAGE_NOW;BAT_CURRENT_NOW;BAT_CAPACITY" > $FILE
}

# Function : showAll
function showAll()
{
    system
    load_average
    cpu
    memory
    battery    
}

# *************************************************************** #
# *                       [ LET'S GO !! ]                       * #
# *************************************************************** #

if [ $# -ge 1 ] ; then
    
    while getopts "Csenpcmltdavhuf-:" option
    do
        case $option in
            h) header ;;
            a) showAll ;;
            ?) echo "Option -$OPTARG inconnue"; exit ;;
            *) exit ;;
        esac
    done
fi