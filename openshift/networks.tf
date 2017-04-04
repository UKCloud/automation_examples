resource "openstack_networking_router_v2" "internet_gw" {
  region = ""
  name   = "${var.router_name}"
  external_gateway = "${var.OS_INTERNET_ID}"
}

resource "openstack_networking_network_v2" "openshift" {
  name = "OpenShift"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "openshift_subnet" {
  name       = "openshift_network"
  network_id = "${openstack_networking_network_v2.openshift.id}"
  cidr       = "${var.OpenShift_Subnet}"
  ip_version = 4
  enable_dhcp = "true"
  allocation_pools = { start = "${cidrhost(var.OpenShift_Subnet, 50)}"
                       end = "${cidrhost(var.OpenShift_Subnet, 200)}" } 
  dns_nameservers  = [ "${cidrhost(var.DMZ_Subnet, 5)}" ]
}

resource "openstack_networking_network_v2" "dmz" {
  name = "DMZ"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "dmz_subnet" {
  name       = "dmz_network"
  network_id = "${openstack_networking_network_v2.dmz.id}"
  cidr       = "${var.DMZ_Subnet}"
  ip_version = 4
  enable_dhcp = "true"
  allocation_pools = { start = "${cidrhost(var.DMZ_Subnet, 50)}"
                       end = "${cidrhost(var.DMZ_Subnet, 200)}" } 
  dns_nameservers  = [ "${cidrhost(var.DMZ_Subnet, 5)}" ]
}

resource "openstack_networking_router_interface_v2" "gw_if_1" {
  region = ""
  router_id = "${openstack_networking_router_v2.internet_gw.id}"
  subnet_id = "${openstack_networking_subnet_v2.dmz_subnet.id}"
}

resource "openstack_networking_router_interface_v2" "gw_if_2" {
  region = ""
  router_id = "${openstack_networking_router_v2.internet_gw.id}"
  subnet_id = "${openstack_networking_subnet_v2.openshift_subnet.id}"
}
