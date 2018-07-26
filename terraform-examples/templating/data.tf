data "openstack_compute_flavor_v2" "small" {
    name = "${var.flavors["small"]}"
}

data "openstack_compute_flavor_v2" "medium" {
    name = "${var.flavors["medium"]}"
}

data "openstack_compute_flavor_v2" "large" {
    name = "${var.flavors["large"]}"
}

data "openstack_networking_network_v2" "internet" {
    name = "internet"
}

data "openstack_images_image_v2" "ubuntu" {
    name = "${var.ubuntu[var.cloud_name]}"
}

data "openstack_images_image_v2" "centos" {
    name = "${var.centos[var.cloud_name]}"
}
