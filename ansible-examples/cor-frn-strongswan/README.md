# UKCloud Strongswan VPN

This Ansible playbook creates an IPSec VPN connecting two
sets of networks residing on COR and FRN clouds.

## Openstack Configuration

Configure the file `clouds.yaml` in the playbook root with the credentials
for both FRN and COR.

    clouds:
      demo-cor:
        auth:
          auth_url: https://cor00005.cni.ukcloud.com:13000/v2.0
          tenant_name: "Eric Williams Test Account COR"
          username: ewilliams@ukcloud.com
          password: "password"
      demo-frn:
        auth:
          auth_url: https://frn00006.cni.ukcloud.com:13000/v2.0
          tenant_name: Eric Williams Test Account FRN
          username: ewilliams@ukcloud.com
          password: "password"


## Cloud FRN

### Hosts

* frn-host-a

* frn-host-b

* frn-host-dmz

### Routers

* frn-router

### Networks

* frn-net-a

CIDR: 192.168.1.0/24

* frn-net-b

CIDR: 192.168.2.0/24

* frn-net-dmz

CIDR: 192.168.10.0/24

## Cloud COR

### Routers

* cor-router

### Hosts

* cor-host-a

* cor-host-b

* cor-host-dmz

### Networks

* cor-net-a

CIDR: 192.168.3.0/24

* cor-net-b

CIDR: 192.168.4.0/24

* cor-net-dmz

CIDR: 192.168.11.0/24

