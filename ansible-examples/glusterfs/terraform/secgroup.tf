resource "openstack_networking_secgroup_v2" "gluster" {
    name = "${var.environment}-gluster"
    description = "Rules for Gluster Servers"
}

resource "openstack_networking_secgroup_rule_v2" "gluster_daemon" {
    description = "Gluster Daemon Ports"
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol = "tcp"
    port_range_min = "24000"
    port_range_max = "25000"
    remote_ip_prefix = "192.168.0.0/16"
    security_group_id = "${openstack_networking_secgroup_v2.gluster.id}"
}

resource "openstack_networking_secgroup_rule_v2" "gluster_bricks_nfs" {
    description = "Gluster Brick Ports (NFS)"
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol = "tcp"
    port_range_min = "38465"
    port_range_max = "38467"
    remote_ip_prefix = "192.168.0.0/16"
    security_group_id = "${openstack_networking_secgroup_v2.gluster.id}"
}

resource "openstack_networking_secgroup_rule_v2" "gluster_bricks_glusterfs" {
    description = "Gluster Brick Ports (GlusterFS)"
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol = "tcp"
    port_range_min = "49152"
    port_range_max = "65535"
    remote_ip_prefix = "192.168.0.0/16"
    security_group_id = "${openstack_networking_secgroup_v2.gluster.id}"
}

resource "openstack_networking_secgroup_rule_v2" "gluster_portmapper_tcp" {
    description = "Gluster Brick Ports (GlusterFS)"
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol = "tcp"
    port_range_min = "111"
    port_range_max = "111"
    remote_ip_prefix = "192.168.0.0/16"
    security_group_id = "${openstack_networking_secgroup_v2.gluster.id}"
}

resource "openstack_networking_secgroup_rule_v2" "gluster_portmapper_udp" {
    description = "Gluster Brick Ports (GlusterFS)"
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol = "udp"
    port_range_min = "111"
    port_range_max = "111"
    remote_ip_prefix = "192.168.0.0/16"
    security_group_id = "${openstack_networking_secgroup_v2.gluster.id}"
}

resource "openstack_networking_secgroup_v2" "app" {
    name = "${var.environment}-app"
    description = "App hosts"
}

resource "openstack_networking_secgroup_rule_v2" "app_tcp" {
    count = "${length(var.app_ports_tcp)}"
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol = "tcp"
    port_range_min = "${var.app_ports_tcp[count.index]}"
    port_range_max = "${var.app_ports_tcp[count.index]}"
    remote_ip_prefix = "192.168.0.0/16"
    security_group_id = "${openstack_networking_secgroup_v2.app.id}"
}

resource "openstack_networking_secgroup_v2" "ssh_host" {
    name = "${var.environment}-ssh"
    description = "Hosts reachable via SSH"
}
resource "openstack_networking_secgroup_rule_v2" "ssh_host_rules" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol = "tcp"
    port_range_min = "22"
    port_range_max = "22"
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = "${openstack_networking_secgroup_v2.ssh_host.id}"
}
