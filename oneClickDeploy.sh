#!/bin/bash
SHOULD_WE_SEND="False"
START=0
action1=""
action2=""
SSH_KEY="/root/.ssh/id_rsa"

ansible_bin="/usr/local/bin/ansible-pull"
ansible_folder="/var/lib/ansible/local"
git_repository="https://github.com/ideascube/ansiblecube.git"

script_action=`echo $1 | cut -d= -f1`
action1=`echo $1 | cut -d= -f2 | awk -F "," '{ print $1 }'`
action2=`echo $1 | cut -d= -f2 | awk -F "," '{ print $2 }'`

managed_by_bsf=`echo $2 | cut -d= -f1`
value2=`echo $2 | cut -d= -f2`

ideascube_project_name=`echo $3 | cut -d= -f1`
value3=`echo $3 | cut -d= -f2`

timezone=`echo $4 | cut -d= -f1`
value4=`echo $4 | cut -d= -f2`

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
	echo "[+] Install ansible..."
	update_sources_list
	apt-get update
	apt-get install -y python-pip git python-dev libffi-dev libssl-dev gnutls-bin

	pip install -U distribute
	pip install ansible markupsafe
	pip install cryptography --upgrade

	echo "[+] Clone ansiblecube repo..."
	mkdir --mode 0755 -p /var/lib/ansible/local
	cd /var/lib/ansible/
	git clone https://github.com/ideascube/ansiblecube.git local

	[ ! -d /etc/ansible ] && mkdir /etc/ansible
	cp /var/lib/ansible/local/hosts /etc/ansible/hosts
}

function help()
{
	echo -e "
	YOU HAVE TO BE ROOT TO LUNCH THIS SCRIPT !

	Usage : 
	Create a master :
	./oneClickDeploy.sh script_action=master

	Custom the master: 
	./oneClickDeploy.sh script_action=custom managed_by_bsf=True ideascube_project_name=kb_mooc_cog timezone=Europe/Paris

	You can do both at the same time : 
	./oneClickDeploy.sh script_action=master,custom managed_by_bsf=True ideascube_project_name=kb_mooc_cog timezone=Europe/Paris

	Rename a device : 
	./oneClickDeploy.sh script_action=rename ideascube_project_name=kb_new_name timezone=Africa/Dakar

	- script_action=master|custom|rename : Create a master from scratch or customize the master with specific settings, both option can be used at the same time
	- managed_by_bsf=True|False : Whether send or not log system to a central server. A server with SSH access is required in this case
	- ideascube_project_name=File_Name : Must be the same name as the one used for the ideascube configuration file
	- timezone=Europe/Paris : The timezone
	"
}

if [ "$managed_by_bsf" == "managed_by_bsf" ] && [ "$value2" = True ] && [ ! -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"
	echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org $value3" -N ""
	ssh-copy-id -o StrictHostKeyChecking=no ansible@37.187.151.52

elif [ "$managed_by_bsf" == "managed_by_bsf" ] && [ "$value2" = True ] && [ -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"

elif [ "$managed_by_bsf" == "managed_by_bsf" ] && [ "$value2" = False ]; then

	SHOULD_WE_SEND="False"
fi

ansible_vars="managed_by_bsf=$SHOULD_WE_SEND ideascube_project_name=$value3 timezone=$value4"

if [[ "$action1" == "master" && "$action2" == "custom"  || "$action2" == "master" && "$action1" == "custom" ]] ; then
	TAGS="master,custom"
	EXTRA_VARS="--extra-vars"
	VARS=$ansible_vars
	install_ansible
	START=1
elif [ "$action1" = "master" -a -z "$action2" ]; then
	TAGS="master"
	EXTRA_VARS=""
	VARS=""
	install_ansible
	START=1
elif [ "$action1" = "custom" -a -z "$action2" -a -n "$value2" -a -n "$value3" -a -n "$value4" ]; then
	TAGS="custom"
	EXTRA_VARS="--extra-vars"
	VARS=$ansible_vars
	START=1
elif [ "$action1" = "rename" -a -z "$action2" -a -n "$value2" -a -n "$value3" ]; then
	TAGS="rename"
	EXTRA_VARS="--extra-vars"
	VARS="ideascube_project_name=$value2 timezone=$value3"
	START=1
else
	help
	exit 0;
fi

if [ "$1" = "" ] ; then
	help
fi

if [[ "$START" = "1" ]]; then
	echo "[+] Start ansible-pull..."
	$ansible_bin -C oneUpdateFile -d $ansible_folder -i hosts -U $git_repository main.yml $EXTRA_VARS "$VARS" --tags "$TAGS"
	echo "[+] Done."
fi

