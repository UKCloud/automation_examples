#!/bin/bash

echo "WARNING: Do not use on production environments!"
echo
# remove environment variables, otherwise openstack command will prefer them over
# clouds.yaml

unset OS_AUTH_URL
unset OS_PASSWORD
unset OS_REGION_NAME
unset OS_TENANT_ID
unset OS_TENANT_NAME
unset OS_USERNAME
BREAK=no

if [ ! -f demo-key ]; then

    if openstack --os-cloud=demo-frn keypair show demo-key &>/dev/null; then
        echo "Key pair 'demo-key' exists but no key file found."
        echo "Remove 'demo-key' from openstack using the following commandf:"
        echo "  openstack --os-cloud=demo-frn keypair delete demo-key"
        echo
        BREAK=yes
    fi
    if openstack --os-cloud=demo-cor keypair show demo-key &>/dev/null; then
        echo "Key pair 'demo-key' exists but no key file found."
        echo "Remove 'demo-key' from openstack using the following commandf:"
        echo "  openstack --os-cloud=demo-cor keypair delete demo-key"
        echo 
        BREAK=yes
    fi
    
    if [[ "${BREAK}" == "yes" ]]; then
        exit 1
    fi
    
    echo "Creating demo-key"
    ssh-keygen -f demo-key  -t rsa -N '' &>/dev/null
    
    echo "Adding SSH key to COR"
    openstack --os-cloud=demo-frn \
        keypair create --public-key demo-key.pub demo-key

    echo "Adding SSH key to COR"
    openstack --os-cloud=demo-cor \
        keypair create --public-key demo-key.pub demo-key

fi


ansible-playbook create-demo.yaml $*