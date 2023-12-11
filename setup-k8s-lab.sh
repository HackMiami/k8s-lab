#!/usr/bin/env bash

# This script is to prep the system to have below:
# A python virtual evn with ansible

# The tested and working version of python is 3.11.3
# This script will install pyenv and python 3.11.3 if not installed

# A ssh key for ansible to use

# confirms extra tools are installed like:
#  jq, pwgen, sshpass, terraform

# Its is setup to work on OSX, Ubuntu

# For OSX it will install brew and xcode tools if not installed



# This function ckecks for .linode_token
function ckeck_linode_token {
   if [ -f ".linode_token" ]; then
       echo " .linode_token exists [ OK ]"
   else
       echo " .linode_token doesn't not exist."
       echo " Please create a linode token and save it to .linode_token"
       echo " You can create a token here:"
       echo " https://cloud.linode.com/profile/tokens"
       echo " Token needs to have read_write access to linodes"
       exit
   fi
}

# This are the vars for the script to run
# Name of the virtual env to be created
VIRTUALENV_NAME='py-lab'

# do not change SSH_KEYPATH - this is referenced in ansible/vars.yml
SSH_KEYPATH=~/.ssh/k8s-lab


# This is to see if devbox is installed
DEVBOX=`which devbox`

CURRENT_DIR=`pwd`

echo " PRECHECK Starting "

ckeck_linode_token

# check if devbox is installed
if [ $DEVBOX != "" ]; then
   echo " devbox exists [ OK ]"
else
   echo " devbox doesn't not exist."
   echo " Please install devbox"
   echo " curl -fsSL https://get.jetpack.io/devbox | bash "
   exit 1
fi

# check if DEVBOX_SHELL_ENABLED=1 is set
if [ "$DEVBOX_SHELL_ENABLED" == "1" ]; then
:
else
   echo " ERROR: not running devbox shell"
   echo " --------------------------------------------"
   echo " > devbox shell"
   exit 1
fi

# setup python env and install ansible in it
source ./scripts/setup_python_env.sh

## check if SSH_KEYPATH exists, ask to create it if not...
if [ -f $SSH_KEYPATH ]; then
   echo " $SSH_KEYPATH exists, we'll use that..."
else
   echo " $SSH_KEYPATH wasn't found, generate it now..."
   ssh-keygen -f $SSH_KEYPATH
fi
echo " Adding ssh-key to agent [ OK ]"
ssh-add $SSH_KEYPATH

echo " PRECHECK Complete "

echo " ---- "
echo " User input required now "
echo " ---- "

## get ansible configs setup...

read -r -p "Writing default.ini and terraform.tfvars? [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   cd $CURRENT_DIR/ansible/
   password=`pwgen -1 12`
   echo " Setting the ROOT password to: $password"
   python $CURRENT_DIR/scripts/mk_default.py -e -f $CURRENT_DIR/ansible/default.ini -k pass -v $password
   echo " credentials written to default.ini"
   echo " ---- "

   #### Terraform
   token=`cat $CURRENT_DIR/.linode_token`
   cd $CURRENT_DIR/terraform
   echo -en "token = \"$token\"\n" > terraform.tfvars
   echo -en "pass = \"$password\"\n" >> terraform.tfvars
   cd $CURRENT_DIR
fi

#### Terraforms
echo " ---- "
echo " This is destructive, it will destroy all linodes and recreate them if they exist"
read -r -p "Create linodes with terraform? [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   cd $CURRENT_DIR/terraform
   terraform init
   terraform apply -auto-approve
   cd $CURRENT_DIR
fi

echo " ---- "
read -r -p "Create inventory.yml? [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   python $CURRENT_DIR/scripts/mk_inventory.py $CURRENT_DIR
fi

# Setup k8s packages on the linodes
echo " ---- "
read -r -p "RUN ansible-playbook -f 20 k8s_base.yml -i inventory.yml [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   cd $CURRENT_DIR/ansible
   ansible-playbook -f 20 k8s_base.yml -i inventory.yml
fi

# Run kubeadm -init for the masters
# and save join commands.
echo " -- Going to setup the clusters -- "
echo " ansible-playbook -f 20 k8s_master.yml -i inventory.yml --limit master "
echo " ansible-playbook -f 20 nodes.yml -i inventory.yml --limit node "
echo " ansible-playbook -f 20 reboot.yml -i inventory.yml "
read -r -p "RUN  [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   cd $CURRENT_DIR/ansible
   ansible-playbook -f 20 k8s_master.yml -i inventory.yml --limit master

   ansible-playbook -f 20 nodes.yml -i inventory.yml --limit node

   ansible-playbook -f 20 reboot.yml -i inventory.yml
fi

# Run setup helm
echo " --Going to setup Helm, Nginx-ingress, OpenEBS and ArgCD -- "
echo " ansible-playbook -f 20 helm.yml -i inventory.yml --limit master "
echo " ansible-playbook -f 20 nginxingress-helm.yml -i inventory.yml --limit master "
echo " ansible-playbook -f 20 openebs-helm.yml -i inventory.yml --limit master "
echo " ansible-playbook -f 20 argocd-helm.yml -i inventory.yml --limit master-1 "
read -r -p "RUN [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   cd $CURRENT_DIR/ansible
   ansible-playbook -f 20 helm.yml -i inventory.yml --limit master

   ansible-playbook -f 20 nginxingress-helm.yml -i inventory.yml --limit master

   ansible-playbook -f 20 openebs-helm.yml -i inventory.yml --limit master

   ansible-playbook -f 20 argocd-helm.yml -i inventory.yml --limit master-1
fi

# Run setup consul on the masters
echo " -- Going to setup Consul and peering ATL and Dallas -- "
echo " ansible-playbook -f 20 consul-helm.yml -i inventory.yml --limit master "
echo " ansible-playbook -f 20 peering-consul-atlanta.yml -i inventory.yml --limit master-1 "
echo " ansible-playbook -f 20 peering-consul-dallas.yml -i inventory.yml --limit master-2 "
echo " ansible-playbook -f 20 client-deployments.yml -i inventory.yml --limit master "
echo " ansible-playbook -f 20 server-deployment.yml -i inventory.yml --limit master-2 "
echo " ansible-playbook -f 20 server-access-intention.yml -i inventory.yml --limit master-2 "
echo " ansible-playbook -f 20 server-export-service.yml -i inventory.yml --limit master-2 "
read -r -p "RUN [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   cd $CURRENT_DIR/ansible
   ansible-playbook -f 20 consul-helm.yml -i inventory.yml --limit master

   ansible-playbook -f 20 peering-consul-atlanta.yml -i inventory.yml --limit master-1

   ansible-playbook -f 20 peering-consul-dallas.yml -i inventory.yml --limit master-2

   ansible-playbook -f 20 client-deployments.yml -i inventory.yml --limit master

   ansible-playbook -f 20 server-deployment.yml -i inventory.yml --limit master-2

   ansible-playbook -f 20 server-access-intention.yml -i inventory.yml --limit master-2

   ansible-playbook -f 20 server-export-service.yml -i inventory.yml --limit master-2
fi

# Run setup vault with etcd storage backend
echo " -- Going to setup Vault with ETCd for ha -- "
echo " ansible-playbook -f 20 vault-etcd.yml -i inventory.yml --limit master-1 "
echo " ansible-playbook -f 20 vault-kube.yml -i inventory.yml --limit master-1 "
echo " ansible-playbook -f 20 vault-inject-demo.yml -i inventory.yml --limit master-1 "
read -r -p "RUN  [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then
   cd $CURRENT_DIR/ansible
   ansible-playbook -f 20 vault-etcd.yml -i inventory.yml --limit master-1

   ansible-playbook -f 20 vault-kube.yml -i inventory.yml --limit master-1

   ansible-playbook -f 20 vault-inject-demo.yml -i inventory.yml --limit master-1
fi



echo " ---- "
echo " ---- "
echo " DONE  - I leave you here..."
echo " in the k8s_env folder you will find atlanta_env and dallas_env "
echo " you can source one of the fills to open ports for the services"
echo " you need kubectl and consul installed on your system"
echo " ---- "
echo " https://127.0.0.1:4343 - consul "
echo " https://127.0.0.1:8200 - vault  ATL only"
echo " https://127.0.0.1:8080 - argocd ATL only"
echo " ---- "
echo " You can install jenkins from the argocd ui and the helm chart"
echo " https://charts.jenkins.io"
echo " Set the storageClass to openebs-hostpath "
echo " https://127.0.0.1:8090 - jenkins "
echo " To get the jenkins password run this command:"
echo " kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode ; echo "
echo " ---- "
echo " Other apps to install:"
echo "https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard"
