
# This is to see if apt-get is installed
APT=`which apt-get`
# This is to see if pyenv is installed
PYENV=`which pyenv`


if [ "$PYENV" == "" ]; then
   read -r -p "Do you want to install pyenv and dependencies? [y/N] " response
   response=${response,,}
   if [[ "$response" =~ ^(yes|y)$ ]]; then
      echo " Going to apt-get installing pyenv Dependencies [ OK ]"
      sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl

      echo " Installing pyenv [ OK ]"
      curl https://pyenv.run | bash
      echo " Going to add lines to ~/.bashrc"
      echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
      echo 'eval "$(pyenv init -)"' >> ~/.bashrc
      echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.
      source ~/.bashrc
   fi
else
   echo " pyenv is installed [ OK ]"
fi

# Checking to see if jq is installed
JQ=`which jq`
if [ "$JQ" == "" ]; then
   echo " jq is not installed"
   echo " going to install jq"
   sudo apt-get install -y jq
else
   echo " jq is installed [ OK ]"
fi

# Checking to see if pwgen is installed
PWGEN=`which pwgen`
if [ "$PWGEN" == "" ]; then
   echo " pwgen is not installed"
   echo " going to install pwgen"
   sudo apt-get install -y pwgen
else
   echo " pwgen is installed [ OK ]"
fi

# Checking to see if terraform is installed
TERRA=`which terraform`
if [ "$TERRA" == "" ]; then
   echo " terraform is not installed"
   echo " going to install the needed repos and packages"
   sudo apt update && sudo apt install -y gnupg software-properties-common
   wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
   gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install -y terraform
else
   echo " terraform is installed [ OK ]"
fi

# Confirm sshpass is installed
SSHPASS=`which sshpass`
if [ "$SSHPASS" == "" ]; then
   echo " going to run sshpass apt install sshpass -y"
   sudo apt update
   sudo apt install sshpass -y
else
   echo " sshpass is installed [OK]"
fi
