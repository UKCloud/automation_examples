openstack_subnet
================

An ansible role to wrap up the creation of neutron network and subnets.

Requirements
------------

This role uses the OpenStack module and requires the python-shade package 
to be installed on the host executing the play. These requirements can be
installed using pre_tasks blocks:
```
  pre_tasks:
    - name: Install python-shade pre-reqs
      become: true
      yum:
        name: "{{ item }}"
        state: present
      with_items:
        - epel-release
        - python-pip
        - gcc
        - python-devel
        - libffi-devel
        - openssl-devel

    - name: Install python-shade
      become: true
      pip:
        name: shade
```


Role Variables
--------------
```
network_name: new_network
subnet_name: new_subnet
subnet_cidr: 192.168.1.0/24
gateway_ip: 192.168.1.1
allocation_pool_start: 192.168.1.10
allocation_pool_end: 192.168.1.200
dns_servers:
  - 8.8.8.8
```

Example Playbook
----------------

```
---
- name: Deploy OpenStack Network and Subnet
  hosts: localhost
  roles:
    - role: openstack_subnet
      network_name: demo_network1
      subnet_name: demo_subnet1
      subnet_cidr: 10.0.0.0/24
      gateway_ip: 10.0.0.1
      allocation_pool_start: 10.0.0.10
      allocation_pool_end: 10.0.0.200
```
License and Authors
-------------------
Authors:
  * Rob Coward (rcoward@ukcloud.com)

Copyright 2016 UKCloud

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.