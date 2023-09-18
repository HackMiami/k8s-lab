#!/usr/bin/env bash


read -r -p "Remove python env py-lab? [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]
then
   rm -rf py-lab
   rm -f .python-version
else
   exit
fi


