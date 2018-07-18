#!/bin/bash

# workaround for setting default routes until os_router allows it

unset OS_AUTH_URL
unset OS_PASSWORD
unset OS_REGION_NAME
unset OS_TENANT_ID
unset OS_TENANT_NAME
unset OS_USERNAME

# don't run if snapshot already exists...
openstack --os-cloud demo-${1} volume snapshot show "${3}" -f json && exit 0
# force lets us make a snapshot while still attached
openstack --os-cloud demo-${1} volume snapshot create --force --volume ${2} -f json  "${3}"
# openstack --os-cloud demo-${1} volume snapshot show "${3}" -f json
