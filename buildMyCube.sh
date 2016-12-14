#!/bin/bash

# init vars
START=0
SSH_KEY="/root/.ssh/id_rsa"
MANAGMENT="managed_by_bsf=True"
TIMEZONE="timezone=Europe/Paris"
CONFIGURE="own_config_file=False"
TAGS="--tags master,custom"
LOCK_ACTION=0

# configuration
ANSIBLE_ETC="/etc/ansible/facts.d/"
ANSIBLE_BIN="/usr/local/bin/ansible-pull"
ANSIBLECUBE_PATH="/var/lib/ansible/local"
GIT_REPO_URL="https://github.com/ideascube/ansiblecube.git"
BRANCH="oneUpdateFile"

DISTRIBUTION_CODENAME=$(lsb_release -sc)

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
    cat <<EOF > /etc/apt/sources.list
deb http://ftp.fr.debian.org/debian/ jessie main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free

# jessie-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ jessie-updates main contrib non-free

# jessie-backports, previously on backports.debian.org
deb http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free
EOF
}

function install_ansible()
{
    internet_check

    echo -n "[+] Updating APT cache... "
    update_sources_list
    apt-get update --quiet --quiet
    echo 'Done.'

    echo -n "[+] Install ansible... "
    apt-get install --quiet --quiet -y python-pip git python-dev libffi-dev libssl-dev gnutls-bin
    pip install ansible markupsafe
    pip install cryptography --upgrade
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
    echo "[+] Please enter password to copy SSH public key"
    ssh-copy-id -o StrictHostKeyChecking=no ansible@idbvpn.bsf-intranet.org
    ssh-copy-id -o StrictHostKeyChecking=no ansible@tincmaster.wan.bsf-intranet.org
}

function 3rd_party_app()
{
    CONFIGURE="own_config_file=True"
    KALITE=False
    MEDIACENTER=False
    ZIM=False

    mkdir -p "$ANSIBLE_ETC"

    dialog --msgbox 'Please answere to the following questions to install 3rd party applications' 5 80

    if (dialog  --yesno "Install Khan Academy MOOC application ?" 5 50) then
        KALITE=True
        lang=$(dialog --separate-output --checklist "Choose Khan Academy supported language:" 20 60 3 \
                fr French on\
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
        ZIM=True
        
        wget http://catalog.ideascube.org/kiwix.yml -O /tmp/kiwix.yml > /dev/null 2>&1
        zim_files=$(egrep "\.[a-z][a-z]:|\.[a-z][a-z][a-z]:|size" /tmp/kiwix.yml | sed 's/    size: //' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/://')

        cmd=(dialog --stdout --no-items \
                --separate-output \
                --ok-label "Add" \
                --checklist "Select packages to install :" 100 100 40)
        choices=$("${cmd[@]}" ${zim_files})

        ZIM_LIST=`echo $choices | sed 's/ /","/g'`

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
        },
        \"zim_install\": {
            \"activated\": \""$ZIM\"",
            \"name\": [\""$ZIM_LIST"\"]
        }
    }
}
" > /etc/ansible/facts.d/device_list.fact
        hostname $FULL_NAME
    fi
}

function help()
{
    echo -e "

    [+] Build My Cube [+]

    Usage:

    $0 -n device_name [-t|--timezone] [-m|--managment] [-h|--hostname] [-a|--action] [-b|--branch]

    Arguments :
        -n|--name       Name of your device. 
                        An Ideascube configuration template can be choosen from the links below :
                            + https://github.com/ideascube/ansiblecube/blob/oneUpdateFile/roles/set_custom_fact/files/device_list.fact
                            + https://github.com/ideascube/ideascube/tree/master/ideascube/conf
                        Ex: -n kb_mooc_cog

        -t|--timezone   The timezone. 
                        Default : Europe/Paris
                        Ex: -t Africa/Dakar

        -b|--branch     Set Github branch you'd like to use 
                        Default : oneUpdateFile

        -m|--managment  Install BSF tools, set to false if not from BSF
                        Default : True
                        Ex: -m true|false

        -h|--hostname   Set the server hostname, 
                        Default : Equal to -n
                        Ex: -h my_hostname.lan

        -a|--action     Type of action : master / custom / rename / update / zim_install / idc_import / kalite_import
                        Default : master,custom
                        Ex: -a rename

                        - master        : Install Ideascube and Kiwix server with strict minimal configuration
                                          Nginx, Network-manager, Hostapd, DnsMasq, Iptables rules
                        - custom        : This action will use the -n and -t parameter to configure your device.
                                          It will also install and configure third party application such as Kalite, Media-center content, Zim files
                        - rename        : Rename a device (-n and -t parameter can be redefined)
                        - update        : Run a full update on the device (same will be done at each Internet connection)
                        - zim_install   : Special command that will only run the download/installation of zim files
                        - idc_import    : Special command that will only mass import media in the media-center
                        - kalite_import : Special command that will only import content for Kalite

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

# main

[ $EUID -eq 0 ] || {
    echo "Error: you have to be root to run this script." >&2
    exit 1
}

[ "$DISTRIBUTION_CODENAME" == jessie ] || {
    echo "Error: AnsibleCube run exclusively on Debian Jessie" >&2
    exit 1
}

[ $# -ne 0 ] || help

# Get argument from command line
while [[ $# -gt 0 ]]
do
    case $1 in
        -a|--action)

            case $2 in
                "rename")
                    LOCK_ACTION=1
                    MANAGMENT=""
                    CONFIGURE=""
                ;;

                "update"|"zim_install"|"idc_import"|"kalite_import")
                    LOCK_ACTION=1
                    MANAGMENT=""
                    START=1
                    TIMEZONE=""
                    CONFIGURE=""
                ;;
            esac

            LOCK_ACTION=1
            TAGS="--tags $2"

        shift # past argument
        ;;

        -m|--managment)

            if [ "$2" = "True" ]
            then
                MANAGMENT="managed_by_bsf=True"
                [ -f "$SSH_KEY" ] || generate_rsa_key
            else
                MANAGMENT="managed_by_bsf=False"
            fi

        shift # past argument
        ;;

        -n|--name)
            NAME="ideascube_project_name=$2"
            FULL_NAME=`echo "$2" | sed 's/_/-/g'`

            wget https://raw.githubusercontent.com/ideascube/ansiblecube/$BRANCH/roles/set_custom_fact/files/device_list.fact -O /tmp/device_list.fact > /dev/null 2>&1

            if [[ -z `grep "$FULL_NAME" /tmp/device_list.fact` ]]
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
            HOST_NAME="hostname=$2"
        shift # past argument
        ;;

        -b|--branch)
            BRANCH=$2
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

if [[ "$START" = "1" ]]; then

    if [[ "$CONF" = "1" ]]; then
        apt-get --quiet --quiet install dialog
        3rd_party_app
    fi

    [ -x /usr/local/bin/ansible ] || install_ansible
    [ -d ${ANSIBLECUBE_PATH} ] || clone_ansiblecube

    echo "[+] Start ansible-pull... (log: /var/log/ansible-pull.log)"
    echo "Launching : $ANSIBLE_BIN -C $BRANCH -d $ANSIBLECUBE_PATH -i hosts -U $GIT_REPO_URL main.yml --extra-vars "$MANAGMENT $NAME $TIMEZONE $HOST_NAME $CONFIGURE" $TAGS"
    $ANSIBLE_BIN -C $BRANCH -d $ANSIBLECUBE_PATH -i hosts -U $GIT_REPO_URL main.yml --extra-vars "$MANAGMENT $NAME $TIMEZONE $HOST_NAME $CONFIGURE" $TAGS > /var/log/ansible-pull.log 2>&1
    
    echo "[+] Send ansible-pull report"

    status=$(tail -3 /var/log/ansible-pull.log)
    device_hostname=$(hostname)

    case $status in
        *"failed=1"*)
            wget http://report.bsf-intranet.org/device=$device_hostname/ansiblepull=fail > /dev/null 2>&1
        ;;
        *"failed=0"*)
            wget http://report.bsf-intranet.org/device=$device_hostname/ansiblepull=success > /dev/null 2>&1
        ;;
        *"Local modifications exist in repository"*)
            wget http://report.bsf-intranet.org/device=$device_hostname/ansiblepull=modificationExist > /dev/null 2>&1
        ;;
    esac

    echo "[+] Done."
fi
