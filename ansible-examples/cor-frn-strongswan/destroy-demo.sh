#!/bin/bash

case $1 in
nodocker)
        OS="openstack --os-cloud "
        ;;
    *)
        OS="docker run --entrypoint=openstack --rm -it -v \
            $(pwd):/ansible/playbooks/ ukcloud/demo-client --os-cloud "
        ;;
esac

echo "WARNING: Do not use on production environments!"

# remove environment variables, otherwise openstack command will prefer them over
# clouds.yaml

unset OS_AUTH_URL
unset OS_PASSWORD
unset OS_REGION_NAME
unset OS_TENANT_ID
unset OS_TENANT_NAME
unset OS_USERNAME

# check if clouds.yaml exists

[ ! -f clouds.yaml ] && \
    echo "Configuration file \"clouds.yaml\" not found. Exiting... " && \
    exit 1

read -n 1 -s -r -p "Press any key to continue or ^C to break"
echo ""
for CLOUD in cor frn; do
  CMD="${OS} demo-${CLOUD}"
  # remove the floating IPs
  # wish there were an easy way to get them... :(
  PORT_ID=$(${CMD} port list |grep "${CLOUD}-port-dmz"|cut -f 2 -d "|")
  echo ${CLOUD} port: ${PORT_ID}
  
  # Get the right floating ip
  [ -n "${PORT_ID}" ] && \
      IP_ID=$(${CMD} floating ip list | grep "${PORT_ID}" | cut -f 2 -d "|")
  echo ${CLOUD} ip: ${IP_ID}

  # delete the floating IP
  [ -n "${IP_ID}" ]&& \
      ${CMD} floating ip delete ${IP_ID}
  
  # delete the neutron port
  [ -n "${PORT_ID}" ] && \
      ${CMD} port delete ${PORT_ID}
  
  # delete the hosts
  echo "Deleting servers in ${CLOUD}"
  (${CMD} server delete ${CLOUD}-host-dmz
  ${CMD} server delete ${CLOUD}-host-a
  ${CMD} server delete ${CLOUD}-host-b)2>/dev/null
  
  echo "Cleaning up networks in ${CLOUD}"
  for subnet in a b dmz; do
    SUB_ID=$(${CMD} subnet list|grep "${CLOUD}-subnet-${subnet}" | cut -f 2 -d "|")
    for PORT_ID in $(${CMD} port list | grep ${SUB_ID} | cut -f 2 -d "|"); do
      [ -n "${PORT_ID}" ] && ${CMD} port set ${PORT_ID} --device-owner none
      [ -n "${PORT_ID}" ] && ${CMD} port delete ${PORT_ID}
    done
    [ -n "${SUB_ID}" ] && ${CMD} subnet delete ${SUB_ID}
  done
  
  # delete the subnets
  echo Deleting subnets from ${CLOUD}
  
  (${CMD} subnet delete ${CLOUD}-subnet-dmz 
  ${CMD} subnet delete ${CLOUD}-subnet-a
  ${CMD} subnet delete ${CLOUD}-subnet-b)2>/dev/null
  # delete the networks
  echo Deleting networks from ${CLOUD}
  (${CMD} network delete ${CLOUD}-net-dmz
  ${CMD} network delete ${CLOUD}-net-a
  ${CMD} network delete ${CLOUD}-net-b)2>/dev/null
  
  echo Deleting routers from ${CLOUD}
  (${CMD} router unset --external-gateway ${CLOUD}-router
  ${CMD} router delete ${CLOUD}-router)2>/dev/null
done

  
  