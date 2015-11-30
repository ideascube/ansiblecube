 #!/bin/bash
SHOULD_WE_SEND="False"
SSH_KEY="/root/.ssh/id_rsa" 

sudo apt-get update
sudo apt-get install -y python-pip git python-dev
sudo pip install ansible markupsafe
sudo mkdir /etc/ansible
sudo mkdir -p /var/lib/ansible/local
cd /var/lib/ansible/
git clone https://github.com/ideascube/ansiblecube.git local

if [ "$1" = sync ] && [ ! -f "$SSH_KEY" ]; then
	SHOULD_WE_SEND="True"
	echo -e "\n\n\n" | ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 4096 -C "it@bibliosansfrontieres.org" -N ""
	ssh-copy-id -o StrictHostKeyChecking=no ansible@37.187.151.52 
else
	SHOULD_WE_SEND="True"
fi

sudo cp /var/lib/ansible/local/hosts /etc/ansible/hosts
/usr/local/bin/ansible-pull -d /var/lib/ansible/local -i hosts -U https://github.com/ideascube/ansiblecube.git -C ideasbox globalInstall.yml --extra-vars "use_hdd=True send_to_central_server="$SHOULD_WE_SEND" import_ideascube_data=False download_data=False ideascube_id=$2 timezone=$3"
