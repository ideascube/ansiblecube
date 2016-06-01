#!/bin/bash
SHOULD_WE_SEND="False"
SSH_KEY="/root/.ssh/id_rsa" 

sync_log=`echo $1 | cut -d= -f1`
value1=`echo $1 | cut -d= -f2`

ideascube_id=`echo $2 | cut -d= -f1`
value2=`echo $2 | cut -d= -f2`

timezone=`echo $3 | cut -d= -f1`
value3=`echo $3 | cut -d= -f2`

echo "$sync_log"


if [ "$sync_log" = sync_log ] && [ "$value1" = True ] && [ ! -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"
	echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org" -N ""
	ssh-copy-id -o StrictHostKeyChecking=no ansible@37.187.151.52 

elif [ "$sync_log" = sync_log ] && [ "$value1" = True ] && [ -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"

elif [ "$sync_log" = "sync_log" ] && [ "$value1" = False ]; then

	SHOULD_WE_SEND="False"
else
	echo -e "
	YOU HAVE TO BE ROOT TO LUNCH THIS SCRIPT !

	Usage : ./oneClickDeploy.sh sync_log=True ideascube_id=kb_mooc_cog timezone=Europe/Paris

	sync_log=True|False : Whether send or not log system to a central server. A server with SSH access is required in this case
	ideascube_id=File_Name : Must be the same name as the one used for the ideascube configuration file
	timezone=Europe/Paris : The timezone
	"
	exit 0;
fi

echo "[+] Install ansible..."
sed -i -e '/^deb cdrom/d' /etc/apt/sources.list
apt-get update
apt-get install -y python-pip git python-dev
pip install ansible==1.9.4 markupsafe

echo "[+] Clone ansiblecube repo..."
mkdir --mode 0755 -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube.git local

[ ! -d /etc/ansible ] && mkdir /etc/ansible
cp /var/lib/ansible/local/hosts /etc/ansible/hosts

echo "[+] Run globalInstall playbook..."
/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git globalInstall.yml --extra-vars "sync_log="$SHOULD_WE_SEND" ideascube_id=$value2 timezone=$value3"

echo "[+] Done."
