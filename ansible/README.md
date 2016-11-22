Ansible Playbook and Roles Examples
===============================

This directory contains some example roles that make use of the ansible openstack module. The openstack module makes use of the standard OS_* environment variables defined in the openrc file you can download from https://cor00005.cni.ukcloud.com/dashboard/project/access_and_security/?tab=access_security_tabs__api_access_tab

Playbooks:
* openstack_infrastructure.yml - uses the 2 roles to create 2 networks / subnets and a router attached to the internet.

To run a playbook, install ansible and run:
```
. ~/my-openrc.sh
ansible-playbook openstack_infrastructure.yml
```

## Windows users
Since ansible will only run in a linux environment, this directory also includes a Vagrantfile configuration file that defines a CentOS7 vm, installs ansible inside the VM, and shares this current directory into the VM as the playbook directory under the vagrant user's home directory.

To use these ansible example on a windows desktop, first download and install Oracle VirtualBox and Vagrant, then run:
```
vagrant up ansible
vagrant ssh ansible
cd playbooks
ansible-playbook openstack_infrastructure.yml
```

License and Authors
-------------------
Authors:
  * Rob Coward (rcoward@ukcloud.com)

Copyright 2016 UKCloud

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
