#!/bin/bash
SHOULD_WE_SEND="False"
SSH_KEY="/root/.ssh/id_rsa"

managed_by_bsf=`echo $1 | cut -d= -f1`
value1=`echo $1 | cut -d= -f2`

ideascube_project_name=`echo $2 | cut -d= -f1`
value2=`echo $2 | cut -d= -f2`

timezone=`echo $3 | cut -d= -f1`
value3=`echo $3 | cut -d= -f2`

wifi_passwd=`echo $4 | cut -d= -f1`
value4=`echo $4 | cut -d= -f2`

echo "$managed_by_bsf"


if [ "$managed_by_bsf" = managed_by_bsf ] && [ "$value1" = True ] && [ ! -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"
	echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org" -N ""
	ssh-copy-id -o StrictHostKeyChecking=no ansible@37.187.151.52

elif [ "$managed_by_bsf" = managed_by_bsf ] && [ "$value1" = True ] && [ -f "$SSH_KEY" ]; then

	SHOULD_WE_SEND="True"

elif [ "$managed_by_bsf" = "managed_by_bsf" ] && [ "$value1" = False ]; then

	SHOULD_WE_SEND="False"
else
	echo -e "
	YOU HAVE TO BE ROOT TO LUNCH THIS SCRIPT !

	Usage : ./oneClickUpdate.sh managed_by_bsf=True ideascube_project_name=kb_mooc_cog timezone=Europe/Paris wifi_passwd=789R7E987E89

	managed_by_bsf=True|False : Whether send or not log system to a central server. A server with SSH access is required in this case
	ideascube_project_name=File_Name : Must be the same name as the one used for the ideascube configuration file
	timezone=Europe/Paris : The timezone
	wifi_passwd : You can set the Wifi password. It must be > 8 char
	"
	exit 0;
fi

echo "[+] Clone ansiblecube repo..."
mkdir --mode 0755 -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube-custom-master.git local

[ ! -d /etc/ansible ] && mkdir /etc/ansible
cp /var/lib/ansible/local/hosts /etc/ansible/hosts

echo "[+] Run globalInstall playbook..."
/usr/local/bin/ansible-pull -C oneUpdateFile -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git main.yml --extra-vars "managed_by_bsf="$SHOULD_WE_SEND" ideascube_project_name=$value2 timezone=$value3 wifi_passwd=$value4" --tags "custom"

echo "[+] Done."
