#!/bin/bash

# workaround for setting default routes until os_router allows it 

unset OS_AUTH_URL
unset OS_PASSWORD
unset OS_REGION_NAME
unset OS_TENANT_ID
unset OS_TENANT_NAME
unset OS_USERNAME

openstack --os-cloud demo-${1} router set ${1}-router --route destination=${2},gateway=${3}
