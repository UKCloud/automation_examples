# HEAT Orchestration Template Examples

These are some example templates used with UKCloud's Cloud Native Infrastructure. 

----------

The example.yaml file can be used directly from the Horizon Dashboard by specifying the URL to the raw file when creating a new stack: https://raw.githubusercontent.com/UKCloud/automation_examples/master/heat/example.yaml

This template takes two parameters:

 - Flavor Type
 - Image Name

When deployed, this stack will create from scratch a complete N-Tier Application environment in OpenStack, starting with a Network / Subnet and router connected to the External Network, creating a number of security groups, and then launching instances to support the following:

 - Jumpbox Server with associated floating IP address.
 - Load Balancer Server with associated floating IP address.
 - 2 x Web Servers.
 - Database Server created on persistent volumes.

