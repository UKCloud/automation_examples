#!/bin/bash

unset OS_AUTH_URL
unset OS_PASSWORD
unset OS_REGION_NAME
unset OS_TENANT_ID
unset OS_TENANT_NAME
unset OS_USERNAME

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
            $(pwd):/backups/ ukcloud/demo-client --os-cloud demo-frn"
        ANSIBLE_PLAYBOOK="docker run --entrypoint=ansible-playbook --rm -it -v \
            $(pwd):/ansible/playbooks/ ukcloud/demo-client"
        TERRAFORM="docker run --entrypoint=terraform --rm -it -v \
            $(pwd):/ansible/playbooks/ ukcloud/demo-client"
        ;;
esac

if [ ! -f snapshot-demo-key ]; then

    if ${OPENSTACK} --os-cloud=demo-frn keypair show snapshot-demo-key &>/dev/null; then
        echo "Key pair 'demo-key' exists but no key file found."
        echo "Remove 'demo-key' from openstack using the following commandf:"
        echo "  ${OPENSTACK} --os-cloud=demo-frn keypair delete snapshot-demo-key"
        echo
        BREAK=yes
    fi
    if ${OPENSTACK} --os-cloud=demo-cor keypair show snapshot-demo-key &>/dev/null; then
        echo "Key pair 'snapshot-demo-key' exists but no key file found."
        echo "Remove 'snapshot-demo-key' from openstack using the following commandf:"
        echo "  ${OPENSTACK} --os-cloud=demo-cor keypair delete snapshot-demo-key"
        echo
        BREAK=yes
    fi

    if [[ "${BREAK}" == "yes" ]]; then
        exit 1
    fi

    echo "Creating snapshot-demo-key"
    ssh-keygen -f snapshot-demo-key  -t rsa -N '' &>/dev/null

    echo "Adding SSH key to COR"
    ${OPENSTACK} --os-cloud=demo-cor \
        keypair create --public-key snapshot-demo-key.pub snapshot-demo-key

fi


${ANSIBLE_PLAYBOOK} -i inventory/ create-demo.yaml $*

echo "==========="
echo
echo "Run '$TERRAFORM' destroy to remove the environment"
