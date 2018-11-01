resource "openstack_networking_network_v2" "dmz" {
    name = "${var.environment}-dmz"
}

resource "openstack_networking_subnet_v2" "dmz" {
    network_id = "${openstack_networking_network_v2.dmz.id}"
    name = "${var.environment}-dmz"
    cidr = "${var.cidr["dmz"]}"
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

resource "openstack_networking_network_v2" "app" {
    name = "${var.environment}-app"
}

resource "openstack_networking_subnet_v2" "app" {
    name = "${var.environment}-app"
    network_id = "${openstack_networking_network_v2.app.id}"
    cidr = "${var.cidr["app"]}"
    dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_v2" "router" {
    name = "${var.environment}-router"
    external_network_id = "${data.openstack_networking_network_v2.internet.id}"
}

// interfaces
// dmz
resource "openstack_networking_router_interface_v2" "dmz" {
    subnet_id = "${openstack_networking_subnet_v2.dmz.id}"
    router_id = "${openstack_networking_router_v2.router.id}"
}

// storage
resource "openstack_networking_router_interface_v2" "storage" {
    subnet_id = "${openstack_networking_subnet_v2.storage.id}"
    router_id = "${openstack_networking_router_v2.router.id}"
}

// app
resource "openstack_networking_router_interface_v2" "app" {
    subnet_id = "${openstack_networking_subnet_v2.app.id}"
    router_id = "${openstack_networking_router_v2.router.id}"
}

resource "openstack_networking_floatingip_v2" "floatip" {
    pool = "internet"
}
