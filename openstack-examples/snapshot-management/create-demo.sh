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

if [ ! -d .terraform ]; then
    echo "Please run terraform init in this directory"
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
        ;;
esac

${ANSIBLE_PLAYBOOK} -i inventory/ create-demo.yaml