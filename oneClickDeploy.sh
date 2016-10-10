#!/bin/bash

# init vars
SHOULD_WE_SEND="False"
START=0
action1=""
action2=""
SSH_KEY="/root/.ssh/id_rsa"

# configuration
ansible_bin="/usr/local/bin/ansible-pull"
ansible_folder="/var/lib/ansible/local"
git_repository="https://github.com/ideascube/ansiblecube.git"

# parse args
arg_managed_by_bsf=`echo $1 | cut -d= -f2`
arg_ideascube_project_name=`echo $2 | cut -d= -f2`
arg_timezone=`echo $3 | cut -d= -f2`

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

function test_three_args()
{
	if [[ -z $arg_managed_by_bsf || -z $arg_ideascube_project_name || -z $arg_timezone ]]
    then
        echo "[/!\] No arguments supplied"
		help
	fi
}

function test_two_args()
{
	if [[ -z $arg_ideascube_project_name || -z $arg_timezone ]]
    then
        echo "[/!\] No arguments supplied"
		help
	fi
}

function generate_rsa_key()
{
	SHOULD_WE_SEND="True"
	echo "[+] Generating public/private rsa key pair"
	echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org $arg_ideascube_project_name" -N "" > /dev/null 2>&1
	echo "[+] Please enter password to copy SSH public key"
	ssh-copy-id -o StrictHostKeyChecking=no ansible@idbvpn.bsf-intranet.org
}

function help()
{
	echo -e "
	YOU HAVE TO BE ROOT TO LAUNCH THIS SCRIPT !

	Usage:

	A master is only a system with Ideascube and Kiwix server with strict minimal
	configuration. Once a master has been created, you have to customize your device
	and you can install, Ka-lite, import zim and so on. Check out:
	https://github.com/ideascube/ansiblecube/blob/oneUpdateFile/roles/set_custom_fact/files/device_list.fact

	Create a master:
	./oneClickDeploy.sh master

	[===OR===]

	Create a master_bsf (install BSF tools):
	./oneClickDeploy.sh master_bsf

	[===AND===]

	Customize your master:
	./oneClickDeploy.sh ideascube_project_name=kb_mooc_cog timezone=Europe/Paris

	[===OR===]

	Create and customize your master at the same time:
	./oneClickDeploy.sh managed_by_bsf=True ideascube_project_name=kb_mooc_cog timezone=Europe/Paris

	Arguments:
	- managed_by_bsf=True|False : Install BSF tools, don't set to True if you are not part of BSF

	- ideascube_project_name=File_Name : Must be the same name as the one used for the ideascube configuration file

	- timezone=Europe/Paris : The timezone
	"
	exit 0;
}

# main

[ $EUID -eq 0 ] || {
    echo "Error: you have to be root to run this script." >&2
    exit 1
}

if [ "$1" = "master" ]
then
	TAGS="master"
	EXTRA_VARS="--extra-vars"
	VARS="managed_by_bsf=False"
	START=1
elif [ "$1" = "master_bsf" ]
then
	[ -f "$SSH_KEY" ] || generate_rsa_key
	TAGS="master"
	EXTRA_VARS="--extra-vars"
	VARS="managed_by_bsf=True"
	START=1
elif [ -x /usr/bin/ideascube ]
then
	test_two_args

	TAGS="custom"
	EXTRA_VARS="--extra-vars"
	VARS="ideascube_project_name=$arg_ideascube_project_name timezone=$arg_timezone"
	START=1
else
	test_three_args

	if [[ ! -f "$SSH_KEY" && "$arg_managed_by_bsf" = "True" ]]; then
		generate_rsa_key
	fi
	TAGS="master,custom"
	EXTRA_VARS="--extra-vars"
	VARS="managed_by_bsf=$arg_managed_by_bsf ideascube_project_name=$arg_ideascube_project_name timezone=$arg_timezone"
	START=1
fi

if [[ "$START" = "1" ]]; then

	[ -x /usr/local/bin/ansible ] || install_ansible
	[ -d /var/lib/ansible/local ] || clone_ansiblecube

	echo "[+] Start ansible-pull... (log: /var/log/ansible-pull.log)"
	$ansible_bin -C oneUpdateFile -d $ansible_folder -i hosts -U $git_repository main.yml $EXTRA_VARS "$VARS" --tags "$TAGS" > /var/log/ansible-pull.log 2>&1
	echo "[+] Done."
fi
