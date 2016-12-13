# Configure the OpenStack Provider
provider "openstack" {
    user_name   = "${var.OS_USERNAME}"
    tenant_name = "${var.OS_TENANT_NAME}"
    password    = "${var.OS_PASSWORD}"
    auth_url    = "${lookup(var.OS_AUTH_URL, var.PLATFORM)}"
    insecure    = "true"
}

resource "openstack_networking_router_v2" "internet_gw" {
  region = ""
  name   = "${var.router_name}"
  external_gateway = "${lookup(var.OS_INTERNET_ID, var.PLATFORM)}"
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
  dns_nameservers  = [ "${cidrhost(var.Management_Subnet, 5)}" ]
}

resource "openstack_networking_network_v2" "management" {
  name = "Management"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "management_subnet" {
  name       = "management_network"
  network_id = "${openstack_networking_network_v2.management.id}"
  cidr       = "${var.Management_Subnet}"
  ip_version = 4
  enable_dhcp = "true"
  allocation_pools = { start = "${cidrhost(var.Management_Subnet, 50)}"
                       end = "${cidrhost(var.Management_Subnet, 200)}" } 
  dns_nameservers  = [ "${cidrhost(var.Management_Subnet, 5)}" ]
}

resource "openstack_networking_router_interface_v2" "gw_if_1" {
  region = ""
  router_id = "${openstack_networking_router_v2.internet_gw.id}"
  subnet_id = "${openstack_networking_subnet_v2.management_subnet.id}"
}

resource "openstack_networking_router_interface_v2" "gw_if_2" {
  region = ""
  router_id = "${openstack_networking_router_v2.internet_gw.id}"
  subnet_id = "${openstack_networking_subnet_v2.openshift_subnet.id}"
}


resource "openstack_compute_keypair_v2" "ssh-keypair" {
  name       = "terraform-keypair"
  public_key = "${file(var.public_key_file)}"
}



