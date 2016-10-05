# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=root

# If ansible_ssh_user is not root, ansible_sudo must be set to true
#ansible_sudo=true

deployment_type=origin

# uncomment the following to enable htpasswd authentication; defaults to DenyAllPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
# Defining htpasswd users
openshift_master_htpasswd_users={'admin': '$apr1$ZG/Jv4JT$XUQ3.aZ4DlGI.fIDnva.s.'}

# Native high availbility cluster method with optional load balancer.
# If no lb group is defined installer assumes that a load balancer has
# been preconfigured. For installation the value of
# openshift_master_cluster_hostname must resolve to the load balancer
# or to one or all of the masters defined in the inventory if no load
# balancer is present.
openshift_master_cluster_method=native
openshift_master_cluster_hostname=${cluster_hostname}.${domain_name}
openshift_master_cluster_public_hostname=${cluster_hostname}.${domain_name}
openshift_master_default_subdomain=${app_subdomain}.${domain_name}

# Cloud Provider Configuration
#
# Note: You may make use of environment variables rather than store
# sensitive configuration within the ansible inventory.
# For example:
#openshift_cloudprovider_openstack_username="{{ lookup('env','OS_USERNAME') }}"
#openshift_cloudprovider_openstack_password="{{ lookup('env','OS_PASSWORD') }}"
#
# Openstack
openshift_cloudprovider_kind=openstack
openshift_cloudprovider_openstack_auth_url=${OS_AUTH_URL}
openshift_cloudprovider_openstack_username=${OS_USERNAME}
openshift_cloudprovider_openstack_password=${OS_PASSWORD}
openshift_cloudprovider_openstack_tenant_id=${OS_TENANT_ID}
openshift_cloudprovider_openstack_tenant_name=${OS_TENANT_NAME}
openshift_cloudprovider_openstack_region=${OS_REGION}
#openshift_cloudprovider_openstack_lb_subnet_id=subnet_id


# host group for masters
[masters]
${master_ipaddress}

# host group for nodes, includes region info
[nodes]
${master_nodes}
${compute_nodes}
