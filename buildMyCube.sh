#!/bin/bash

# init vars
START=0
SSH_KEY="/root/.ssh/id_rsa"
MANAGMENT="managed_by_bsf=True"
TIMEZONE="timezone=Europe/Paris"
TAGS="--tags master,custom"
LOCK_ACTION=0

# configuration
ansible_bin="/usr/local/bin/ansible-pull"
ansible_folder="/var/lib/ansible/local"
git_repository="https://github.com/ideascube/ansiblecube.git"

# functions
function internet_check()
{
    echo "[+] Check Internet connection"
    if [[ ! `ping -q -c 2 github.com` ]]
    then
        echo "[+] Repository is unreachable, check your Internet connection" >&2
        exit 1
    fi
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

    echo "[+] Install ansible..."
    update_sources_list
    apt-get update
    apt-get install -y python-pip git python-dev libffi-dev libssl-dev gnutls-bin

    pip install -U distribute
    pip install ansible markupsafe
    pip install cryptography --upgrade
}

function clone_ansiblecube()
{
    internet_check

    echo "[+] Clone ansiblecube repo..."
    mkdir --mode 0755 -p /var/lib/ansible/local
    cd /var/lib/ansible/
    git clone https://github.com/ideascube/ansiblecube.git local

    mkdir --mode 0755 -p /etc/ansible
    cp /var/lib/ansible/local/hosts /etc/ansible/hosts
}

function generate_rsa_key()
{
    echo "[+] Generating public/private rsa key pair"
    echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org $NAME" -N "" > /dev/null 2>&1
    echo "[+] Please enter password to copy SSH public key"
    ssh-copy-id -o StrictHostKeyChecking=no ansible@idbvpn.bsf-intranet.org
}

function 3rd_party_app()
{
    CONFIGURE="configure=true"
	dialog --title 'Message' --msgbox 'Please answere to the following questions to install 3rd party applications' 5 80
	dialog --title "Message"  --yesno "Install Khan Academy MOOC application ?" 6 25
	kalite=$?

	if [ "$kalite" == "0" ]
	then
		KALITE=True
		dialog --checklist "Choose Khan Academy supported language:" 20 60 3 \
				1 fr on\
				2 ar off\
				3 es off 2> KALITE_LANG
	fi
	echo "LANG $KALITE_LANG"
    echo "Install BSF Campus MOOC application ? (true/false)"
    read -r BSFCAMPUS
    echo "Install Khan Academy MOOC application ? (true/false)"
    read -r KALITE
    echo "Choose language for Khan Academy : \"fr\",\"ar\",\"sw\""
    read -r KALITE_LANG
    echo "Mass import media in the media-center ? (true/false)"
    read -r MEDIACENTER
    echo "Path to CSV file to media-center mass import"
    read -r MEDIACENTER_PATH
    echo "Download offline ZIM files ? (true/false)"
    read -r KIWIX
    echo "Offline ZIM file you whish to install : \"wikipedia.fr\",\"wikipedia.en\""
    read -r KIWIX_FILE

    echo -e "
{
    \"$FULL_NAME\": {
        \"bsfcampus\": {
            \"activated\": \"$BSFCAMPUS\",
            \"version\": \"080916\"
        },
        \"kalite\": {
            \"activated\": \"$KALITE\",
            \"version\": \"0.16.9\",
            \"language\": [$KALITE_LANG]
        },
        \"idc_import\": {
            \"activated\": \"$MEDIACENTER\",
            \"content_name\": [\"$MEDIACENTER_PATH\"]
        },
        \"zim_install\": {
            \"activated\": \"$KIWIX\",
            \"name\": [$KIWIX_FILE]
        }
    }
}
    " > /etc/ansible/facts.d/device_list.fact
}

function help()
{
    echo -e "

    [+] Build My Cube [+]

    Usage:

    $0 [-t|--timezone] [-m|--managment] [-h|--hostname] [-a|--action] [-c|--configure] -n device_name

    Arguments :
        -n|--name       Name of Ideascube configuration file
                        Ex: -n kb_mooc_cog

        -t|--timezone   The timezone. Default : Europe/Paris
                        Ex: -t Europe/Paris

        -m|--managment  Install BSF tools. Default : True
                        Ex: -m true|false

        -h|--hostname   Set the server hostname, otherwise use of --name parameter
                        Ex: -h my_hostname

        -a|--action     Type of action needed : master / rename / update / zim_install / idc_import / kalite_import
                        Ex: -a rename

        -c|--configure  Choose which 3rd party applications to install on your device
                        Ex: -c true|false

                        - master : Ideascube and Kiwix server with strict minimal configuration
                        - rename : Rename a device
                        - update : Action that will be executed at each device update

    Few exemples :
        [+] Create a master based on kb_bdi_irc Ideascube template
        $0 -n kb_bdi_irc -a master

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
                ;;

                "update"|"zim_install"|"idc_import"|"kalite_import")
                    LOCK_ACTION=1
                    MANAGMENT=""
                    START=1
                    TIMEZONE=""
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

        -c|--configure)
            CONF="1"
        shift # past argument
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
        3rd_party_app
    fi

    [ -x /usr/local/bin/ansible ] || install_ansible
    [ -d /var/lib/ansible/local ] || clone_ansiblecube

    echo "[+] Start ansible-pull... (log: /var/log/ansible-pull.log)"
    echo "Launching : $ansible_bin -C oneUpdateFile -d $ansible_folder -i hosts -U $git_repository main.yml --extra-vars "$MANAGMENT $NAME $TIMEZONE $HOST_NAME $CONFIGURE" $TAGS"
    $ansible_bin -C oneUpdateFile -d $ansible_folder -i hosts -U $git_repository main.yml --extra-vars "$MANAGMENT $NAME $TIMEZONE $HOST_NAME $CONFIGURE" $TAGS > /var/log/ansible-pull.log 2>&1
    echo "[+] Done."
fi
