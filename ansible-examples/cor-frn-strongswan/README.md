# UKCloud Strongswan VPN

This Ansible playbook creates an IPSec VPN connecting two
sets of networks residing on COR and FRN clouds.

![Cloud to Cloud VPN][diagram]

## Cloud FRN

### Routers

* frn-router

### Networks

| Network     | Network Address |
|-------------|-----------------|
| frn-net-a   |  192.168.1.0/24 |
| frn-net-b   |  192.168.2.0/24 |
| frn-net-dmz | 192.168.10.0/24 |

### Hosts

| Host         | Network     |
---------------|-------------|
| frn-host-a   | frn-net-a   |
| frn-host-b   | frn-net-b   |
| frn-host-dmz | frn-net-dmz |


## Cloud COR

### Routers

* cor-router

### Networks

| Network     | Network Address |
|-------------|-----------------|
| cor-net-a   | 192.168.3.0/24  |
| cor-net-b   | 192.168.4.0/24  |
| cor-net-dmz | 192.168.11.0/24 |

### Hosts

| Host         | Network     |
---------------|-------------|
| cor-host-a   | cor-net-a   |
| cor-host-b   | cor-net-b   |
| cor-host-dmz | cor-net-dmz |

## Getting started

1. Create an SSH keypair for the deployment.  This SSH key will be used for all hosts in the deployment, and is required by Ansible

2. **Install Ansible**: Ansible should be installed on your local machine, preferably in a python `virtualenv` environment.

3. Create your `clouds.yaml` configuration file.  The format of this file is shown in the *UKCloud OpenStack Configuration* section below.

4. Run `ansible-playbook create-demo.yaml` in the root of the project to create the two environments.

### Initial Configuration

Mandatory configuration settings are found in:

* `group_vars/all.yaml`: Add the path to your own key, created in *Getting Started*

* `vars/cloud-vars.yaml`: Add the name of your created SSH key in this file

* Create a python `virtualenv` to install Ansible and the OpenStack clients

```
mkdir -p ~/code/openstack-venv
virtualenv ~/code/openstack-venv
source ~/code/openstack-venv/bin/activate
pip install -r requirements.txt
```

### UKCloud OpenStack Configuration

Copy the file `clouds.yaml.sample` to `clouds.yaml` in the playbook root with the credentials
for both FRN and COR.

    clouds:
      demo-cor:
        auth:
          auth_url: https://cor00005.cni.ukcloud.com:13000/v2.0
          tenant_name: "Contents of OS_TENANT"
          username: user@example.com
          password: "password_goes_here"
      demo-frn:
        auth:
          auth_url: https://frn00006.cni.ukcloud.com:13000/v2.0
          tenant_name: "Contents of OS_TENANT"
          username: user@example.com
          password: "password_goes_here"
    ansible:
      use_hostnames: true


[diagram]:images/Cloud%20to%20Cloud%20VPN.png?raw=true"
