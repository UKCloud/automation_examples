openstack_router
================

An ansible role to wrap up the creation of a router and it's interfaces.

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
router_name: InternetGW
ext_network: internet
subnets: {}
```

```
---
- name: Deploy OpenStack Router and subnet interfaces
  hosts: localhost
  roles:
    - role: openstack_router
      router_name: demo_router
      subnets:
        - demo_subnet1
        - demo_subnet2
```
License and Authors
-------------------
Authors:
  * Rob Coward (rcoward@ukcloud.com)

Copyright 2016 UKCloud

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.