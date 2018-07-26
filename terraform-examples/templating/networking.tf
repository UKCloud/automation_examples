resource "openstack_networking_floatingip_v2" "floatip_1" {
    pool = "${var.floating_ip_pool}"
}

resource "openstack_networking_network_v2" "networks" {
    count = "${var.num_nets}"
    name = "${format("%s_%d", var.network_name, count.index+1)}"
}

resource "openstack_networking_subnet_v2" "subnets" {
    name = "subnet_${count.index+1}"
    count = "${var.num_nets}"
    /*network_name = "${format("%s_%d", var.network_name, count.index)}"*/
    network_id = "${openstack_networking_network_v2.networks.*.id[count.index]}"
    cidr = "${format(var.cidr_template, count.index+1)}"
    dns_nameservers = "${var.dns_servers}"
}

resource "openstack_networking_router_v2" "router_1" {
    name                = "${var.router_name}"
    admin_state_up      = true
    external_network_id = "${data.openstack_networking_network_v2.internet.id}"
}

resource "openstack_networking_router_interface_v2" "interfaces" {
    count = "${var.num_nets}"
    router_id = "${openstack_networking_router_v2.router_1.id}"
    subnet_id = "${openstack_networking_subnet_v2.subnets.*.id[count.index]}"
}


resource "openstack_networking_secgroup_v2" "secgroup_1" {
    name        = "templating-demo-security-group-1"
    description = "Demo Security Group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
    count = "${length(var.allowed_ports)}"
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = "${var.allowed_ports[count.index]}"
    port_range_max    = "${var.allowed_ports[count.index]}"
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}
