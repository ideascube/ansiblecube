#!/bin/bash
SHOULD_WE_SEND="False"
SSH_KEY="/root/.ssh/id_rsa" 

send_to_central_server=`echo $1 | cut -d= -f1`
value1=`echo $1 | cut -d= -f2`

ideascube_id=`echo $2 | cut -d= -f1`
value2=`echo $2 | cut -d= -f2`

timezone=`echo $3 | cut -d= -f1`
value3=`echo $3 | cut -d= -f2`

download_data=`echo $4 | cut -d= -f1`
value4=`echo $4 | cut -d= -f2`

echo "$send_to_central_server"


if [ "$send_to_central_server" = send_to_central_server ] && [ "$value1" = True ] && [ ! -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"
	echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org" -N ""
	ssh-copy-id -o StrictHostKeyChecking=no ansible@37.187.151.52 

elif [ "$send_to_central_server" = send_to_central_server ] && [ "$value1" = True ] && [ -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"

elif [ "$send_to_central_server" = "send_to_central_server" ] && [ "$value1" = False ]; then

	SHOULD_WE_SEND="False"
else
	echo -e "
	YOU HAVE TO BE ROOT TO LUNCH THIS SCRIPT !

	Usage : ./oneClickDeploy.sh send_to_central_server=True ideascube_id=kb_mooc_cog timezone=Europe/Paris download_data=True

	send_to_central_server=True|False : Wether send or not some system information to central server
	ideascube_id=File_Name : Must be the same name as the one used for the ideascube configuration file
	timezone=Europe/Paris : Is the timezone 
	download_data=True|False : Wether download or not data from ZIM project (ex : wikipedia zim file, etc.)
	"
	exit 0;
fi

apt-get update
apt-get install -y python-pip git python-dev
pip install ansible markupsafe
[ ! -d /etc/ansible ] && mkdir /etc/ansible
mkdir -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube.git local

cp /var/lib/ansible/local/hosts /etc/ansible/hosts
/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git globalInstall.yml --extra-vars "send_to_central_server="$SHOULD_WE_SEND" import_ideascube_data=False ideascube_id=$value2 timezone=$value3 download_data=$value4"
