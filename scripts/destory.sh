#!/usr/bin/env bash


read -r -p "destroy vm and clean up? [y/N] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y)$ ]]; then

    cd ../terraform
    terraform destroy -auto-approve

    rm -f terraform.tfstate*
    rm -f terraform.tfvars
    rm -rf .terraform*

    cd ../ansible
    rm -f inventory.yml
    rm -f default.yml

fi

cd ..

./scripts/remove_env.sh
