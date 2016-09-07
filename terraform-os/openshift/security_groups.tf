resource "openstack_networking_secgroup_v2" "any_ssh" {
  name = "External SSH Access"
  description = "Allow SSH access to VMs"
}

resource "openstack_networking_secgroup_rule_v2" "any_ssh_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.any_ssh.id}"
}

resource "openstack_networking_secgroup_v2" "local_ssh" {
  name = "Local SSH Access"
  description = "Allow local SSH access to VMs"
}

resource "openstack_networking_secgroup_rule_v2" "local_ssh_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "${var.Management_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.local_ssh.id}"
}

resource "openstack_networking_secgroup_rule_v2" "local_ssh_rule_2" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  port_range_min = 1
  port_range_max = 255
  remote_ip_prefix = "${var.Management_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.local_ssh.id}"
}

resource "openstack_networking_secgroup_rule_v2" "local_ssh_rule_3" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  port_range_min = 1
  port_range_max = 255
  remote_ip_prefix = "${var.OpenShift_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.local_ssh.id}"
}

resource "openstack_networking_secgroup_rule_v2" "local_ssh_rule_4" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "${var.OpenShift_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.local_ssh.id}"
}

resource "openstack_networking_secgroup_v2" "any_http" {
  name = "External HTTP Access"
  description = "Allow HTTP access to VMs"
}

resource "openstack_networking_secgroup_rule_v2" "any_http_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.any_http.id}"
}

resource "openstack_networking_secgroup_rule_v2" "any_http_rule_2" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 443
  port_range_max = 443
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.any_http.id}"
}

resource "openstack_networking_secgroup_v2" "openshift_network" {
  name = "OpenShift Network Access"
  description = "Allow full access between OpenShift VMs"
}

resource "openstack_networking_secgroup_rule_v2" "openshift_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 1
  port_range_max = 65535
  remote_ip_prefix = "${var.OpenShift_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.openshift_network.id}"
}

resource "openstack_networking_secgroup_rule_v2" "openshift_rule_2" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  port_range_min = 1
  port_range_max = 65535
  remote_ip_prefix = "${var.OpenShift_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.openshift_network.id}"
}

resource "openstack_networking_secgroup_rule_v2" "openshift_rule_3" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  port_range_min = 1
  port_range_max = 255
  remote_ip_prefix = "${var.OpenShift_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.openshift_network.id}"
}

resource "openstack_networking_secgroup_v2" "openshift_endpoints" {
  name = "OpenShift Endpoint Access"
  description = "Allow access to OpenShift API"
}

resource "openstack_networking_secgroup_rule_v2" "openshift_endpoints_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 8443
  port_range_max = 8443
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.openshift_endpoints.id}"
}
