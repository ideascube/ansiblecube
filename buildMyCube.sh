#!/bin/bash

# init vars
START=0
SSH_KEY="/root/.ssh/id_rsa"
MANAGEMENT="managed_by_bsf=True"
TIMEZONE="timezone=Europe/Paris"
CONFIGURE="own_config_file=False"
TAGS="--tags master,custom"
LOCK_ACTION=0
SEND_REPORT=0
KALITE=False
KALITE_LANG=""
MEDIACENTER=False
CSV_FILE_PATH=""
PACKAGES_MANAGEMENT=False
PACKAGES_LIST=""

# configuration
ANSIBLE_ETC="/etc/ansible/facts.d/"
ANSIBLE_BIN="/usr/local/bin/ansible-pull"
ANSIBLECUBE_PATH="/var/lib/ansible/local"
GIT_REPO_URL="https://github.com/ideascube/ansiblecube.git"
BRANCH="oneUpdateFile"
KINTO_URL="http://kinto.bsf-intranet.org/v1/buckets/projets_bsf/collections/kb-idb/records"

DISTRIBUTION_CODENAME=$(lsb_release -sc)

[ $EUID -eq 0 ] || {
    echo "Error: you have to be root to run this script." >&2
    exit 1
}

[ "$DISTRIBUTION_CODENAME" == jessie ] || {
    echo "Error: AnsibleCube run exclusively on Debian Jessie" >&2
    exit 1
}

# functions
function internet_check()
{
    echo -n "[+] Check Internet connection... "
    if [[ ! `ping -q -c 2 github.com` ]]
    then
        echo "ERROR: Repository is unreachable, check your Internet connection." >&2
        exit 1
    fi
    echo "Done."
}

function update_sources_list()
{
    if [[ "Debian" == `lsb_release -is` ]]
    then
    cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ jessie main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free

# jessie-updates, previously known as 'volatile'
deb http://deb.debian.org/debian/ jessie-updates main contrib non-free

# jessie-backports, previously on backports.debian.org
deb http://deb.debian.org/debian/ jessie-backports main contrib non-free
EOF
    fi
}

function install_ansible()
{
    echo -n "[+] Updating APT cache... "
    update_sources_list
    apt-get update --quiet --quiet
    echo 'Done.'

    echo -n "[+] Install ansible... "
    apt-get install --quiet --quiet -y python-pip python-yaml python-jinja2 python-httplib2 python-paramiko python-pkg-resources libffi-dev libssl-dev git dialog lsb-release
    pip install ansible==2.2.0
    echo 'Done.'
}

function clone_ansiblecube()
{
    echo -n "[+] Checking for internet connectivity... "
    internet_check
    echo 'Done.'

    echo -n "[+] Clone ansiblecube repo... "
    mkdir --mode 0755 -p ${ANSIBLECUBE_PATH}
    cd ${ANSIBLECUBE_PATH}/../
    git clone https://github.com/ideascube/ansiblecube.git local

    mkdir --mode 0755 -p /etc/ansible/facts.d
    cp ${ANSIBLECUBE_PATH}/hosts /etc/ansible/hosts
    echo 'Done.'
}

function generate_rsa_key()
{
    echo -n "[+] Generating public/private rsa key pair... "
    echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org $FULL_NAME" -N "" > /dev/null 2>&1
    echo 'Done.'
    while true; do
     ssh -o BatchMode=yes "ansible@tincmaster.wan.bsf-intranet.org" true
     if [[ $? -ne 0 ]]; then
      echo "[+] Please enter password to copy SSH public key"
      ssh-copy-id -o StrictHostKeyChecking=no ansible@tincmaster.wan.bsf-intranet.org
     else
      break
     fi
    done
}

function 3rd_party_app()
{
    CONFIGURE="own_config_file=True"
    KALITE=False
    MEDIACENTER=False
    PACKAGES_MANAGEMENT=False

    mkdir -p "$ANSIBLE_ETC"

    dialog --msgbox 'Please answere to the following questions to install 3rd party applications' 5 80

    if (dialog  --yesno "Install Khan Academy MOOC application ?" 5 50) then
        KALITE=True
        lang=$(dialog --separate-output --checklist "Choose Khan Academy supported language:" 20 60 5 \
                fr French on\
                en English off\
                ar Arabic off\
                es Spanish off 3>&1 1>&2 2>&3 3>&-)

        if [ $? = 0 ]
        then
            KALITE_LANG=`echo $lang | sed 's/ /","/g'`
        else
            exit 0;
        fi
    fi

    if (dialog  --yesno "Mass import media in the media-center ?" 5 60) then
        MEDIACENTER=True

        csv_path=$(dialog --stdout --title "Media-center" --inputbox "Path to CSV file on your device:" 8 40 \
                "/tmp/my_content.csv")

        if [ $? = 0 ]
        then
            CSV_FILE_PATH=$csv_path
        else
            exit 0;
        fi
    fi

    if (dialog  --yesno "Do you want to download offline packages ?" 5 60) then
        PACKAGES_MANAGEMENT=True

        wget -O - http://catalog.ideascube.org/kiwix.yml > /tmp/kiwix.yml 2> /dev/null
        wget -O - http://catalog.ideascube.org/static-sites.yml >> /tmp/kiwix.yml 2> /dev/null
        wget -O - http://catalog.ideascube.org/bibliotecamovil.yml >> /tmp/kiwix.yml 2> /dev/null

        zim_files=$(egrep "\.[a-z][a-z]:|\.[a-z][a-z][a-z]:" /tmp/kiwix.yml | sed 's/://' | sed 's/  //')

        cmd=(dialog --stdout --no-items \
                --separate-output \
                --ok-label "Add" \
                --checklist "Select packages to install :" 100 100 40)
        declare -a PACKAGES_LIST=($("${cmd[@]}" ${zim_files}))
    fi

    echo -e "
{
    \"$FULL_NAME\": {
        \"kalite\": {
            \"activated\": \"$KALITE\",
            \"version\": \"0.16.9\",
            \"language\": [\""$KALITE_LANG"\"]
        },
        \"idc_import\": {
            \"activated\": \"$MEDIACENTER\",
            \"content_name\": ["\"$CSV_FILE_PATH\""]
        }," > /etc/ansible/facts.d/project.fact

    if [ $PACKAGES_MANAGEMENT == "True" ]; then

        echo -e "        \"package_management\":[{
                    \"name\": \"${PACKAGES_LIST[0]}\",
                    \"status\": \"present\"
                " >> /etc/ansible/facts.d/project.fact

        unset PACKAGES_LIST[0]
        for PACKAGE in ${PACKAGES_LIST[@]}; do
        echo -e "                },
                {
                    \"name\": \"$PACKAGE\",
                    \"status\": \"present\"
                " >> /etc/ansible/facts.d/project.fact
        done

        echo -e "                }
        ]," >> /etc/ansible/facts.d/project.fact

    fi

    echo -e "        \"portal\": {
            \"activated\": \"True\"
        }
    }
}" >> /etc/ansible/facts.d/project.fact

        hostname $FULL_NAME
}

function help()
{
    echo -e "

    [+] Build My Cube [+]

    Usage:

    $0 [OPTIONS] -n|--name [device_name]

        -n|--name       Name of your device. 
                        An Ideascube configuration template can be choosen from the links below :
			$KINTO_URL
                        Ex: -n kb_mooc_cog

    OPTIONS :

        -t|--timezone   The timezone. 
                        Default: Europe/Paris
                        Ex: -t Africa/Dakar

        -b|--branch     Set Github branch you'd like to use 
                        Default: oneUpdateFile

        -m|--management  Install BSF tools, set to false if not from BSF
                        Default: true
                        Ex: -m true|false

        -h|--hostname   Set the server hostname, with .lan
                        Default: Equal to --name
                        Ex: -h my_hostname.lan

        -w|--wifi-pwd   Lock the Wifi Hotspot with a password. Must be >= 8 caracteres
                        Default: Open
                        Ex: -w 12ET4690

        -a|--action     Type of action : master / custom / rename / update / package_management / idc_import / kalite_import
                        Default: master,custom
                        Ex: -a rename

                        - master            : Install Ideascube and Kiwix server with strict minimal configuration
                                              Nginx, Network-manager, Hostapd, DnsMasq, Iptables rules
                        - custom            : This action will use the -n and -t parameter to configure your device.
                                              It will also install and configure third party application such as Kalite, Media-center content, Zim files
                        - rename            : Rename a device (-n and -t parameter can be redefined)
                        - update            : Run a full update on the device (same will be done at each Internet connection)
                        - package_management: Special command to manage package : Install, update and remove a package
                        - idc_import        : Special command that will only mass import media in the media-center
                        - kalite_import     : Special command that will only import content for Kalite

    Few examples :
        [+] Create a master based on kb_bdi_irc Ideascube template
        $0 -n kb_bdi_irc -a master

        [+] Full install with personnal settings (no need of -a parameter)
        $0 -n my_box -t Africa/Dakar -m false

        [+] Rename a device
        $0 -n kb_bdi_irc -t Europe/Paris -a rename
     "
    exit 0;
}

function go_manage()
{
    [ -f "$SSH_KEY" ] || generate_rsa_key
    SEND_REPORT="1"
    return $SEND_REPORT
}

# main

[ $# -ne 0 ] || help

internet_check

if [[ -e /etc/ansible/facts.d/project.fact ]]; then
    echo -n "[+] Local configuration file exist, would you like to delete it ? (y/n)" >&2
    read response

    case $response in
        [OoYy]*)
            rm -f /etc/firstStart.csv /etc/ansible/facts.d/project.fact /tmp/project.fact /etc/ansible/facts.d/installed_software.fact
            touch /etc/ansible/facts.d/installed_software.fact
        ;;
        *)
            cp /etc/ansible/facts.d/project.fact /tmp/project.fact
        ;;
    esac
fi

# Get argument from command line
while [[ $# -gt 0 ]]
do
    case $1 in
        -a|--action)

            case $2 in
                "rename")
                    LOCK_ACTION=1
                    MANAGEMENT=""
                    CONFIGURE=""
                ;;

                "update"|"package_management"|"idc_import"|"kalite_import")
                    LOCK_ACTION=1
                    MANAGEMENT=""
                    START=1
                    TIMEZONE=""
                    CONFIGURE=""
                ;;
            esac

            LOCK_ACTION=1
            TAGS="--tags $2"

        shift # past argument
        ;;

        -m|--management)

            [ ${2^^} = "FALSE" ] && MANAGEMENT="managed_by_bsf=False"

        shift # past argument
        ;;

        -n|--name)

            if [ -z "$2" ]
            then
                echo -e "\n\t[+] ERROR\n\t--name : Missing device name\n"

                exit 0;
            fi

            # An SSID length can not exceed 32 characters. SSID == name + _XXX ; do name must be 28 chars max
            [[ ${#2} -gt 28 ]] && {
                echo "Error: the name should be less than 28 characters long." >&2
                exit 16
            }

            NAME="ideascube_project_name=$2"
            FULL_NAME=`echo "$2" | sed 's/_/-/g'`

            [[ -z /etc/ansible/facts.d/project.fact ]] || wget $KINTO_URL/$2 -O /etc/ansible/facts.d/project.fact > /dev/null 2>&1

            if [[ -z /etc/ansible/facts.d/project.fact ]] && [ "$TAGS" != "--tags master" ]
            then
                CONF="1"
            fi

            START=1
        shift # past argument
        ;;

        -t|--timezone)
            TIMEZONE="timezone=$2"
        shift # past argument
        ;;

        -h|--hostname)
            fqdn=`echo $2 | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'`
            if [[ -z "$fqdn" ]]
            then
                echo -e "\n\t[+] ERROR\n\tThe supplied domain name is not valid. Format : domain.extension"
                exit 1
            fi
            HOST_NAME="hostname=$2"
        shift # past argument
        ;;

        -w|--wifi-pwd)
            if [ ${#2} -lt "8" ] ; then
                echo -e "\n\t[+] ERROR\n\tThe supplied password is too short (>= 8)"
                exit 1
            fi
            WIFIPWD="wpa_pass=$2"
        shift # past argument
        ;;

        -b|--branch)
            BRANCH=$2
            GIT_BRANCH="git_branch=$2"
        shift
        ;;

        *)
            help
        ;;
    esac
    shift # past argument or value
done

if [[ -x /usr/bin/ideascube && "$LOCK_ACTION" = "0" ]]
then
    TAGS="--tags custom"
fi

[ "$MANAGEMENT" == managed_by_bsf=True ] && go_manage

if [[ "$START" = "1" ]]; then

    if [[ "$CONF" = "1" ]]; then
        3rd_party_app
    fi

    [ -x /usr/local/bin/ansible ] || install_ansible
    [ -d ${ANSIBLECUBE_PATH} ] || clone_ansiblecube

    echo "Checking file access" >> /var/log/ansible-pull.log
    [ $? -ne 0 ] && echo "No space left to write logs or permission problem, exiting." && exit 1

    echo "$ANSIBLE_BIN -C $BRANCH -d $ANSIBLECUBE_PATH -i hosts -U $GIT_REPO_URL main.yml --extra-vars \"$MANAGEMENT $NAME $TIMEZONE $HOST_NAME $CONFIGURE $WIFIPWD $GIT_BRANCH\" $TAGS" >> /var/lib/ansible/ansible-pull-cmd-line.sh
    echo -e "[+] Command line stored in /var/lib/ansible/ansible-pull-cmd-line.sh"
    echo -e "[+] Launch ansiblepull with following arguments: \n$ANSIBLE_BIN -C $BRANCH -d $ANSIBLECUBE_PATH -i hosts -U $GIT_REPO_URL main.yml --extra-vars \"$MANAGEMENT $NAME $TIMEZONE $HOST_NAME $CONFIGURE $WIFIPWD $GIT_BRANCH\" $TAGS"

    $ANSIBLE_BIN -C $BRANCH -d $ANSIBLECUBE_PATH -i hosts -U $GIT_REPO_URL main.yml --extra-vars "$MANAGEMENT $NAME $TIMEZONE $HOST_NAME $CONFIGURE $WIFIPWD $GIT_BRANCH" $TAGS > /var/log/ansible-pull.log 2>&1

    if [[ "$SEND_REPORT" = "1" ]]; then
        echo "[+] Send ansible-pull report"

        status=$(tail -3 /var/log/ansible-pull.log)
        description=$(grep TASK /var/log/ansible-pull.log | sed -n '$p' | cut -d "[" -f 2 | sed 's/*//g' | sed 's/ /_/g')
        device_hostname=$(hostname)

        case $status in
            *"failed=1"*)
                wget http://report.bsf-intranet.org/device=$device_hostname/ansiblepull=fail/msg="$description" > /dev/null 2>&1
            ;;
            *"failed=0"*)
                wget http://report.bsf-intranet.org/device=$device_hostname/ansiblepull=success > /dev/null 2>&1
            ;;
            *"Local modifications exist in repository"*)
                wget http://report.bsf-intranet.org/device=$device_hostname/ansiblepull=modificationExist > /dev/null 2>&1
            ;;
        esac
    fi

    echo "[+] Done."
else
    echo -e "\n\t[+] ERROR\n\t--name : Missing device name\n"
    exit 0;
fi
