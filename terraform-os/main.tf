# Configure the OpenStack Provider
provider "openstack" {
    #user_name   = "${var.OS_USERNAME}"
    #tenant_name = "${var.OS_TENANT_NAME}"
    #password    = "${var.OS_PASSWORD}"
    #auth_url    = "${var.OS_AUTH_URL}"
    insecure    = "true"
}

resource "openstack_networking_router_v2" "internet_gw" {
  region = ""
  name   = "InternetGW"
  external_gateway = "${var.OS_INTERNET_GATEWAY_ID}"
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
  dns_nameservers  = [ "8.8.8.8" ]
}

resource "openstack_networking_router_interface_v2" "gw_if_1" {
  region = ""
  router_id = "${openstack_networking_router_v2.internet_gw.id}"
  subnet_id = "${openstack_networking_subnet_v2.dmz_subnet.id}"
}

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
  remote_ip_prefix = "${var.DMZ_Subnet}"
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

resource "openstack_networking_secgroup_v2" "local_http" {
  name = "Internal HTTP Access"
  description = "Allow HTTP access from local VMs"
}

resource "openstack_networking_secgroup_rule_v2" "local_http_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  remote_ip_prefix = "${var.DMZ_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.local_http.id}"
}

resource "openstack_networking_secgroup_v2" "local_mysql" {
  name = "Internal MySQL Access"
  description = "Allow MySQL access from local VMs"
}

resource "openstack_networking_secgroup_rule_v2" "local_mysql_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 3306
  port_range_max = 3306
  remote_ip_prefix = "${var.DMZ_Subnet}"
  security_group_id = "${openstack_networking_secgroup_v2.local_mysql.id}"
}

resource "openstack_compute_keypair_v2" "ssh-keypair" {
  name       = "terraform-keypair"
  public_key = "${var.SSH_KEY}"
}

resource "openstack_compute_floatingip_v2" "jumpbox_ip" {
  region = ""
  pool = "${var.FloatingIP_Pool}"
}

resource "openstack_compute_floatingip_v2" "loadbalancer_ip" {
  region = ""
  pool = "${var.FloatingIP_Pool}"
}

resource "openstack_compute_instance_v2" "jumpbox" {
  name        = "jumpbox01"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.INSTANCE_TYPE}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.any_ssh.name}"]
  network {
    name = "${openstack_networking_network_v2.dmz.name}"
  }

}

resource "openstack_compute_floatingip_associate_v2" "jumpbox_ip" {
  floating_ip = "${openstack_compute_floatingip_v2.jumpbox_ip.address}"
  instance_id = "${openstack_compute_instance_v2.jumpbox.id}"
}

resource "openstack_compute_instance_v2" "loadbalancer" {
  name        = "haproxy01"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.INSTANCE_TYPE}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.any_http.name}"]
  network {
    name = "${openstack_networking_network_v2.dmz.name}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "loadbalancer_ip" {
  floating_ip = "${openstack_compute_floatingip_v2.loadbalancer_ip.address}"
  instance_id = "${openstack_compute_instance_v2.loadbalancer.id}"
}

resource "openstack_compute_servergroup_v2" "webservers" {
  name = "webserver-servergroup"
  policies = ["anti-affinity"]
  # policies = ["affinity"]
}

resource "openstack_compute_instance_v2" "web" {
  name        = "${format("web%02d", count.index + 1)}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.INSTANCE_TYPE}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.local_http.name}"]
  network {
    name = "${openstack_networking_network_v2.dmz.name}"
  }

  scheduler_hints = { group = "${openstack_compute_servergroup_v2.webservers.id}" }

  count = 2
}

resource "openstack_blockstorage_volume_v1" "db_system" {
  name = "db_system"
  size = 30
  image_id = "${var.IMAGE_ID}"
  description = "System volume for MySQL"
}

resource "openstack_blockstorage_volume_v1" "db_data" {
  region = ""
  name = "db_data"
  description = "data volume for MySQL"
  size = 50
}

resource "openstack_compute_instance_v2" "database" {
  name            = "db01"
  flavor_name     = "${var.DB_INSTANCE_TYPE}"
  key_pair        = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.local_mysql.name}"]

  block_device {
    uuid = "${openstack_blockstorage_volume_v1.db_system.id}"
    source_type = "volume"
    boot_index = 0
    volume_size = "${openstack_blockstorage_volume_v1.db_system.size}"
    destination_type = "volume"
    delete_on_termination = true
  }

  block_device {
    uuid = "${openstack_blockstorage_volume_v1.db_data.id}"
    source_type = "volume"
    boot_index = 1
    volume_size = "${openstack_blockstorage_volume_v1.db_data.size}"
    destination_type = "volume"
    delete_on_termination = true
  }

  network {
    name = "${openstack_networking_network_v2.dmz.name}"
  }
}
