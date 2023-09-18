
function brew_notes {
   echo " --------------------------------------------"
   echo " --------------------------------------------"
   echo " ---- If you're on OSX and you're using brew ----"
   echo " ---- you'll need to add the following to your .bashrc ----"
   echo 'export PATH="/usr/local/bin:$PATH"'
   echo " --------------------------------------------"
   echo " --------------------------------------------"
   echo ""
   echo " Some other troubleshooting notes:"
   echo " --------------------------------------------"
   echo ""
   echo "# if gcc is not install or not working"
   echo "xcode-select --install"
   echo ""
   echo ""
   echo "# if gcc is not working try this."
   echo "xcode-select --reset"
   echo ""
   echo ""
   echo "# if it keeps not working - try removing it."
   echo "ls -l /Library/Developer/CommandLineTools"
   echo "sudo rm -rf /Library/Developer/CommandLineTools"
   echo "xcode-select --install"
   echo ""
   echo ""
   echo "# testing brew"
   echo "brew doctor"
   echo ""
   echo ""
   echo "# testing gcc should show this output"
   echo "> gcc"
   echo "clang: error: no input files"
   echo " --------------------------------------------"
   echo " --------------------------------------------"
}

# This is to check if we're on OSX or Ubuntu
UNAME=`uname`
# This is to see if brew is installed
BREW=`which brew`

echo " Running on OSX [ OK ]"
if [ "$BREW" == "" ]; then
    read -r -p "Do you want to run xcode-select --install and install brew? [y/N] " response
    if [[ "$response" = "y" ]]; then
        echo " Running xcode-select --install"
        sudo xcode-select --install
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O brew_install.sh
        bash brew_install.sh
        echo " Adding brew path to .bashrc"
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
        BREW=`which brew`
        brew_notes
    fi
fi

# Check bash version
echo " Checking bash version"
bash_version=`bash --version | head -n1 | awk '{print $4}' | awk -F'.' '{print $1}'`
if [ $bash_version -gt 4 ]; then
    echo " bash version looks good [ OK ]"
else
    echo " WARNING - bash version less then 4 detected"
    read -r -p "Upgrade bash [y/N] " response
    if [[ "$response" = "y" ]]; then
        brew upgrade
        brew install bash
        echo $(brew --prefix)/bin/bash | sudo tee -a /private/etc/shells
        sudo chpass -s $(brew --prefix)/bin/bash $USER
        echo " bash version upgraded. "
        echo " Please restart the script"
        exit
    else
        echo " Sorry you need to upgrade bash for this to work"
        exit
    fi
fi

# This is to see if pyenv is installed
PYENV=`which pyenv`
if [ "$PYENV" == "" ]; then
   read -r -p "Do you want to install pyenv and dependencies? [y/N] " response
   response=${response,,}
    if [[ "$response" =~ ^(yes|y)$ ]]; then
        echo " Going to brew installing pyenv Dependencies [ OK ]"
        brew install openssl readline sqlite3 xz zlib

        echo " Installing pyenv [ OK ]"
        curl https://pyenv.run | bash
        echo " Going to add lines to ~/.bashrc"
        echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.
        source ~/.bashrc
    else
        echo "Sorry you need to install pyevn and dependencies for this to work"
        exit
   fi
else
   echo " pyenv is installed [ OK ]"
fi

# Checking to see if jq is installed
JQ=`which jq`
if [ "$JQ" == "" ]; then
    echo " jq is not installed"
    echo " going to install jq"
    brew install jq
else
   echo " jq is installed [ OK ]"
fi


# Checking to see if pwgen is installed
PWGEN=`which pwgen`
if [ "$PWGEN" == "" ]; then
    echo " pwgen is not installed"
    echo " going to install pwgen"
    brew install pwgen
else
   echo " pwgen is installed [ OK ]"
fi

# Checking to see if terraform is installed
TERRA=`which terraform`
if [ "$TERRA" == "" ]; then
    echo " terraform is not installed"
    echo " going to install the needed repos and packages"
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    brew update
    brew upgrade hashicorp/tap/terraform
else
   echo " terraform is installed [ OK ]"
fi

# Confirm sshpass is installed
SSHPASS=`which sshpass`
if [ "$SSHPASS" == "" ]; then
    echo " sshpass is needed and needs to be installed."
    brew tap esolitos/ipa
    brew install esolitos/ipa/sshpass
else
   echo " sshpass is installed [OK]"
fi
