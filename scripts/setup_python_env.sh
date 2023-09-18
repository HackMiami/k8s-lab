
deactivate ()
{
    if [ -n "${_OLD_VIRTUAL_PATH:-}" ]; then
        PATH="${_OLD_VIRTUAL_PATH:-}";
        export PATH;
        unset _OLD_VIRTUAL_PATH;
    fi;
    if [ -n "${_OLD_VIRTUAL_PYTHONHOME:-}" ]; then
        PYTHONHOME="${_OLD_VIRTUAL_PYTHONHOME:-}";
        export PYTHONHOME;
        unset _OLD_VIRTUAL_PYTHONHOME;
    fi;
    if [ -n "${BASH:-}" -o -n "${ZSH_VERSION:-}" ]; then
        hash -r 2> /dev/null;
    fi;
    if [ -n "${_OLD_VIRTUAL_PS1:-}" ]; then
        PS1="${_OLD_VIRTUAL_PS1:-}";
        export PS1;
        unset _OLD_VIRTUAL_PS1;
    fi;
    unset VIRTUAL_ENV;
    unset VIRTUAL_ENV_PROMPT;
    if [ ! "${1:-}" = "nondestructive" ]; then
        unset -f deactivate;
    fi
}

# This are the vars for the script to run
# Name of the virtual env to be created
VIRTUALENV_NAME='py-lab'


CURRENT_DIR=`pwd`

# Test if we're in a virtual env
if [ "$VIRTUAL_ENV" == "" ]; then
   echo " WE'RE NOT IN A VIRTUAL_ENV [ OK ]"
else
   echo " WARNING IN A VIRTUAL_ENV"
   echo $VIRTUAL_ENV
   echo " Deactivating [ OK ]"
   deactivate
fi

_ENV_WANT=$CURRENT_DIR/$VIRTUALENV_NAME

PYTHON=`which python3`

# setup env install passlib and ansible  activate env
if [ -d "$_ENV_WANT" ]; then
  echo "$_ENV_WANT does exist"
  echo " activating $_ENV_WANT [ OK ]"
  source $_ENV_WANT/bin/activate
  echo " Now using $VIRTUAL_ENV [ OK ]"
else
  echo "$_ENV_WANT does not exist."
  echo " creating env [ OK ]"
  $PYTHON -m venv $_ENV_WANT
  echo " activating $_ENV_WANT [ OK ]"
  source $_ENV_WANT/bin/activate
  echo " Now using $VIRTUAL_ENV [ OK ]"
fi

# Install ansible and passlib if missing
if [ -f "$_ENV_WANT/bin/ansible" ]; then
  echo " ansible is installed [ OK ]"
else
   echo " installing ansible and passlib"
   pip install ansible passlib requests ping3 PyYAML
fi

# Confirm ansible ansible-playbook and ansible-galaxy is installed
ansible_installed=$(which ansible)
ansible_playbook_installed=$(which ansible-playbook)
ansible_galaxy_installed=$(which ansible-galaxy)

if [ "$ansible_installed" == "" ]; then
   echo " !!! ansible isn't installed...you'll need to install ansible, then run this script again!!!"
   exit
elif [ "$ansible_playbook_installed" == "" ]; then
   echo " !!! ansible-playbook isn't installed...you'll need to install ansible, then run this script again!!!"
   exit
elif [ "$ansible_galaxy_installed" == "" ]; then
   echo " !!! ansible-galaxy isn't installed...you'll need to install ansible, then run this script again!!!"
   exit
else
   echo " ansible installed, installing additional required Galaxy modules... [ OK ]"
   ansible-galaxy collection install ansible.posix community.general
fi

