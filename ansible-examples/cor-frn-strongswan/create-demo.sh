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

export ANSIBLE_GATHERING=smart
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_RETRY_FILES_ENABLED=false

if [ ! -f clouds.yaml ]; then
    echo "Please create a valid clouds.yaml"
    exit 1
fi



case ${1} in
    nodocker)
        OPENSTACK="openstack"
        ANSIBLE_PLAYBOOK="ansible-playbook"
        ;;
    *)
        DOCKER="docker run --rm -it -v \
            $(pwd):/ansible/playbooks/ ukcloud/demo-client"
        OPENSTACK="docker run --entrypoint=openstack --rm -it -v \
            $(pwd):/ansible/playbooks/ ukcloud/demo-client"
        ANSIBLE_PLAYBOOK="docker run --entrypoint=ansible-playbook --rm -it -v \
            $(pwd):/ansible/playbooks/ ukcloud/demo-client"
        [ -f dockerbuild.log ] || docker build -it ukcloud/demo-client . &> dockerbuild.log
        
        ;;
esac
    
if [ ! -f demo-key ]; then

    if ${OPENSTACK} --os-cloud=demo-frn keypair show demo-key &>/dev/null; then
        echo "Key pair 'demo-key' exists but no key file found."
        echo "Remove 'demo-key' from openstack using the following commandf:"
        echo "  ${OPENSTACK} --os-cloud=demo-frn keypair delete demo-key"
        echo
        BREAK=yes
    fi
    if ${OPENSTACK} --os-cloud=demo-cor keypair show demo-key &>/dev/null; then
        echo "Key pair 'demo-key' exists but no key file found."
        echo "Remove 'demo-key' from openstack using the following commandf:"
        echo "  ${OPENSTACK} --os-cloud=demo-cor keypair delete demo-key"
        echo 
        BREAK=yes
    fi
    
    if [[ "${BREAK}" == "yes" ]]; then
        exit 1
    fi
    
    echo "Creating demo-key"
    ssh-keygen -f demo-key  -t rsa -N '' &>/dev/null
    
    echo "Adding SSH key to COR"
    ${OPENSTACK} --os-cloud=demo-frn \
        keypair create --public-key demo-key.pub demo-key

    echo "Adding SSH key to COR"
    ${OPENSTACK} --os-cloud=demo-cor \
        keypair create --public-key demo-key.pub demo-key

fi


 ${ANSIBLE_PLAYBOOK} create-demo.yaml $*