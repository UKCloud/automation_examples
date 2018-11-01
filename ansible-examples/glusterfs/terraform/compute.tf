# __   ___ __  _ __
# \ \ / / '_ \| '_ \
#  \ V /| |_) | | | |
#   \_/ | .__/|_| |_|
#       |_|

resource "openstack_compute_instance_v2" "vpn" {
    name = "${var.environment}-vpn"
    image_id = "${data.openstack_images_image_v2.centos.id}"
    flavor_id = "${data.openstack_compute_flavor_v2.small.id}"
    key_pair = "${var.key_pair_name}"
    security_groups = [
        "${var.environment}-ssh"
    ]

    metadata {
        groups = "gluster-demo,vpn"
    }
    network {
        uuid = "${openstack_networking_network_v2.vpn.id}"
    }

    depends_on = [
        "openstack_networking_subnet_v2.vpn"
    ]

}

resource "openstack_compute_floatingip_associate_v2" "myip" {
    floating_ip = "${openstack_networking_floatingip_v2.floatip.address}"
    instance_id = "${openstack_compute_instance_v2.vpn.id}"
    fixed_ip = "${openstack_compute_instance_v2.vpn.network.0.fixed_ip_v4}"
}

#        _           _
#   __ _| |_   _ ___| |_ ___ _ __
#  / _` | | | | / __| __/ _ \ '__|
# | (_| | | |_| \__ \ ||  __/ |
# \__, |_|\__,_|___/\__\___|_|
# |___/

resource "openstack_compute_instance_v2" "gluster" {
    key_pair = "${var.key_pair_name}"
    name = "${format("${var.environment}-gluster-%03d", count.index + 1)}"
    count = "${var.gluster_count}"
    # image_id = "${data.openstack_images_image_v2.centos.id}"
    flavor_id = "${data.openstack_compute_flavor_v2.medium.id}"
    security_groups = [
        "${var.environment}-gluster",
        "${var.environment}-ssh"
    ]

    metadata {
        groups = "gluster-demo,gluster"
    }

    network {
        uuid = "${openstack_networking_network_v2.storage.id}"
    }

    block_device {
      boot_index            = 0
      delete_on_termination = true
      destination_type      = "volume"
      source_type           = "image"
      uuid                  = "${data.openstack_images_image_v2.centos.id}"
      volume_size           = 60

    }

    block_device {
      boot_index            = 1
      delete_on_termination = true
      destination_type      = "volume"
      source_type           = "blank"
      volume_size           = 120
    }
    depends_on = [
        "openstack_networking_subnet_v2.storage"
    ]
}

resource "openstack_compute_instance_v2" "compute" {
    key_pair = "${var.key_pair_name}"
    name = "${format("${var.environment}-app-%03d", count.index + 1)}"
    count = "${var.compute_count}"
    image_id = "${data.openstack_images_image_v2.centos.id}"
    flavor_id = "${data.openstack_compute_flavor_v2.small.id}"
    security_groups = [
        "${var.environment}-compute",
        "${var.environment}-ssh"
    ]

    metadata {
        groups = "gluster-demo,compute"
    }

    network {
        uuid = "${openstack_networking_network_v2.compute.id}"
    }

    depends_on = [
        "openstack_networking_subnet_v2.compute"
    ]
}
