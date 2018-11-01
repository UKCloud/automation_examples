resource "openstack_networking_network_v2" "vpn" {
    name = "${var.environment}-vpn"
}

resource "openstack_networking_subnet_v2" "vpn" {
    network_id = "${openstack_networking_network_v2.vpn.id}"
    name = "${var.environment}-vpn"
    cidr = "${var.cidr["vpn"]}"
    dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_network_v2" "storage" {
    name = "${var.environment}-storage"
}

resource "openstack_networking_subnet_v2" "storage" {
    name = "${var.environment}-storage"
    network_id = "${openstack_networking_network_v2.storage.id}"
    cidr = "${var.cidr["storage"]}"
    dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_network_v2" "compute" {
    name = "${var.environment}-compute"
}

resource "openstack_networking_subnet_v2" "compute" {
    name = "${var.environment}-compute"
    network_id = "${openstack_networking_network_v2.compute.id}"
    cidr = "${var.cidr["compute"]}"
    dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_v2" "router" {
    name = "${var.environment}-router"
    external_network_id = "${data.openstack_networking_network_v2.internet.id}"
}

// interfaces
// vpn
resource "openstack_networking_router_interface_v2" "vpn" {
    subnet_id = "${openstack_networking_subnet_v2.vpn.id}"
    router_id = "${openstack_networking_router_v2.router.id}"
}

// storage
resource "openstack_networking_router_interface_v2" "storage" {
    subnet_id = "${openstack_networking_subnet_v2.storage.id}"
    router_id = "${openstack_networking_router_v2.router.id}"
}

// compute
resource "openstack_networking_router_interface_v2" "compute" {
    subnet_id = "${openstack_networking_subnet_v2.compute.id}"
    router_id = "${openstack_networking_router_v2.router.id}"
}

resource "openstack_networking_floatingip_v2" "floatip" {
    pool = "internet"
}
