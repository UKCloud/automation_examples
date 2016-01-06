##  Chef Provisioning (Fog Driver) ##

This directory contains a sample Chef Recipe that can be used in Chef Local Mode (chef-zero) to provision a Jumpbox server, database server and 2 web servers in a vDC on Skyscape Cloud's vCloud Director.

To get started, you will want to install the Chef Development Kit (ChefDK) from https://downloads.chef.io/chef-dk/ and optionally the knife-vcair plugin by running:
```
chef gem install knife-vcair
```
To keep the knife.rb file fairly generic, it reads a number of user specific values from environment variable.

You will need to setup the following environment variables with values for your Skyscape Portal account - these can be found at https://portal.skyscapecloud.com/user/api :
```
VCAIR_ORG=1-2-33-456789
VCAIR_USERNAME=1234.5.67890
VCAIR_PASSWORD=Secret
JUMPBOX_IPADDRESS=XXX.XXX.XXX.XXX
VCAIR_SSH_USERNAME=vagrant
VCAIR_SSH_PASSWORD=vagrant
```
The last two variables are the credentials to use when logging into new VMs created from your vApp Template.


Preparing Cookbooks
-------
The rest of these instruction assume that the commands are run from the chef-provisioning-fog sub-directory of this git repository.

To prepare the my_web_app cookbook and its dependencies for chef provisioning to deploy, you will need to run the commands:
```
berks install
berks vendor cookbooks
```
This will create a cookbooks sub-directory which chef-zero can then share with any VMs created by chef provisioning.

Preparing vCloud Director
-------
The Fog driver for Chef Provisioning has no provision for configuring vDC Networking or the vShield Edge devices used to provide NAT / Firewall / Load Balancer services to your orgainsation's vDC. These will need to be configured manually in advance of running chef provisioining.

 - First create a vDC Routed Network called 'Jumpbox Network' using the CIDR address 10.1.1.0/24 and a static IP pool of 10.1.1.10 - 10.1.1.100.
 
 You can check the networks configured by running:
```
 $ knife vcair network list
Name             Gateway   IP Range Start  End         Description
Jumpbox Network  10.1.1.1  10.1.1.10       10.1.1.100  Demo network for API automation examples
```
 - Assuming the first VM created will be the jumpbox server and that it will be assigned the IP address 10.1.1.10, setup DNAT rules on the vShield Edge for your vDC to forward SSH (port 22) to that addess.
 - Add the associated firewall rules to the vShield Edge to allow incoming SSH connections.
 - Add SNAT rules to the vShield Edge to allow outbound connections from the Jumpbox Network address range to connect to the internet (needed to download chef-client).

Getting it all working
-------
To run the sample chef provisioning recipe and deploy our simple N-Tier web application, run:
```
chef-client -z skyscapecloud-demo.rb
```
Once the VMs and application stack is built, you'll need to make one more manual change to the vShield Edge on your vDC to setup the load-balancing over the 2 web servers.

To clean up all the VMs when you are finished, run:
```
chef-client -z skyscapecloud-delete.rb
```

