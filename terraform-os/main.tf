# Configure the OpenStack Provider
provider "openstack" {
    user_name  = "${var.OS_USERNAME}"
    tenant_name = "${var.OS_TENANT_NAME}"
    password  = "${var.OS_PASSWORD}"
    auth_url  = "${var.OS_AUTH_URL}"
    insecure  = "true"
}

resource "openstack_networking_router_v2" "router_1" {
  region = ""
  name = "my_router"
  external_gateway = "${var.OS_INTERNET_GATEWAY_ID}"
}

resource "openstack_networking_network_v2" "network_1" {
  name = "network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name = "subnet_1"
  network_id = "${openstack_networking_network_v2.network_1.id}"
  cidr = "192.168.199.0/24"
  ip_version = 4
  enable_dhcp = "true"
  allocation_pools = { start = "192.168.199.50"
                       end = "192.168.199.200" } 
  dns_nameservers  = [ "8.8.8.8" ]
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  region = ""
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name = "secgroup_1"
  description = "My neutron security group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_compute_servergroup_v2" "test-sg" {
  name = "my-sg"
  policies = ["anti-affinity"]
  # policies = ["affinity"]
}

resource "openstack_compute_keypair_v2" "ssh-keypair" {
  name = "terraform-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEArrSmhh3oGC/zCorMpOXXppYCRLQMzUpdyQotCuXQ8uD4JHitbReQBT0LuaCtei4xxLcdnpNW7DM/xLfl0yZLWRk0iH5VFjPxvYsgVzhysO8nvG6l2p3RDJOrA2mQROl5yDaAWUE/J2vKezzNJf9f8/JZyuWWafPa89+XTPR3VAuQCzRrCmskW1rpok29IpqM/jM7QCfG20Y7/lLOaCW9UlEAO++WTDQS4X6t6Xf5Lsg6TMGrMuPSQzjUTMGvfhT3dnTuhALLW5bYQirkgAWwSPoHx5yeZZnhH1C0T2ak0Dhx0tlm9sr82DU6x0INWENcdMj95oFlceA5DOqQ/3s3jw=="
}

resource "openstack_compute_instance_v2" "web" {
  name        = "${format("web%02d", count.index + 1)}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.INSTANCE_TYPE}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_1.name}"]

  network {
    name = "${openstack_networking_network_v2.network_1.name}"
  }

  scheduler_hints = { group = "${openstack_compute_servergroup_v2.test-sg.id}" }

  count = 2
}

resource "openstack_compute_instance_v2" "boot-from-volume" {
  name            = "boot-from-volume"
  flavor_name     = "${var.INSTANCE_TYPE}"
  key_pair        = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_1.name}"]

  block_device {
    uuid = "${var.IMAGE_ID}"
    source_type = "image"
    volume_size = 50
    boot_index = 0
    destination_type = "volume"
    delete_on_termination = true
  }

  network {
    name = "${openstack_networking_network_v2.network_1.name}"
  }
}

