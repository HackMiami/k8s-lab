
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

# # python version to be installed
# VERSION=3.9.13

CURRENT_DIR=`pwd`

# # Checking to see if python $VERSION is installed
# check=0
# for versions in `pyenv versions | sed 's/*//' | awk '{print $1}'`; do
#    if [ "$versions" == "$VERSION" ]; then
#       echo " python $VERSION is installed [ OK ]"
#       check=1
#       break
#    fi
# done

# # install python $VERSION if not installed
# if [ $check -eq 0 ]; then
#    source ~/.bashrc
#    echo " going to install python $VERSION with pyenv and setting it to local"
#    pyenv install $VERSION --skip-existing
# fi

# echo " Checking if .python-version matches $VERSION"


# # Test if .python-version exists and if it matches $VERSION
# if [ -f ".python-version" ]; then
#    PYTHON_VERSION=`cat .python-version`
#    if [ "$PYTHON_VERSION" == "$VERSION" ]; then
#       echo " .python-version matches $VERSION [ OK ]"
#    fi
# else
#    echo " .python-version doesn't not exist, creating it. [ OK ]"
#    pyenv local $VERSION
# fi

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
VIRTUALENV=`which virtualenv`
PYTHON_VER=`$PYTHON -V | awk '{print $2}'`
PYTHON_MAJOR=`echo $PYTHON_VER | awk -F'.' '{print $1}'`
PYTHON_MINOR=`echo $PYTHON_VER | awk -F'.' '{print $2}'`
# checking python
if [ $PYTHON_MAJOR -gt 2 ]; then
   if [ $PYTHON_MINOR -gt 7 ]; then
      echo " PYTHON VERSION LOOKS GOOD [ OK ]"
   fi
else
   echo " WARNING - python2 or python3 less then 7 detected"
   exit
fi

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

