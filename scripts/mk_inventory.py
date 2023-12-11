import json
import sys
import yaml

path = sys.argv[1]

terraform_state_file = path + '/terraform/terraform.tfstate'
ansible_inventory_file = path + '/ansible/inventory.yml'

# Load Terraform state JSON from the file
with open(terraform_state_file, 'r') as state_file:
    terraform_state = json.load(state_file)

# Initialize the inventory dictionary
inventory = {'all': {'children': {}}}

region_map = {'us-southeast': 'atlanta', 'us-central': 'dallas', 'us-east': 'newark', 'us-west': 'fremont'}

# Loop through resources in the Terraform state
for resource in terraform_state['resources']:
    instance_name = resource['name']
    attributes = resource['instances'][0]['attributes']

    public_ip = attributes.get('ip_address')
    if public_ip is None:
        continue

    linodeid = attributes.get('id')
    region = attributes.get('region')

    if region in region_map:
        region = region_map[region]
    else:
        continue

    # Add the region to the inventory dictionary
    if region not in inventory['all']['children']:
        inventory['all']['children'].update({region: {'children': {}}})

    # if master in instance_name: - this is master or node
    children_group = instance_name.split('-')[0]
    if children_group not in inventory['all']['children'][region]['children']:
        inventory['all']['children'][region]['children'].update({children_group: {'hosts': {}}})

    # Add the instance to the inventory dictionary
    instance = {instance_name: {'ansible_host': public_ip,
                                'linodeid': linodeid,
                                'host_name': instance_name,
                                'region': region}
                }

    inventory['all']['children'][region]['children'][children_group]['hosts'].update(instance)

# Write the inventory to inventory.yml in YAML format
with open(ansible_inventory_file, 'w') as inventory_file:
    inventory_file.write('---\n')  # Add the --- at the beginning
    yaml.dump(inventory, inventory_file, default_flow_style=False)
