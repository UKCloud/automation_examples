resource "openstack_compute_instance_v2" "servers_1" {
    count = 3
    name            = "templating-demo-node-${format("%02d", count.index+1)}"
    image_id        = "${data.openstack_images_image_v2.ubuntu.id}"
    flavor_id       = "${data.openstack_compute_flavor_v2.small.id}"
    key_pair        = "${var.keypair_name}"
    security_groups = ["default", "templating-demo-security-group-1"]
  
    metadata {
      groups = "templating-demo,${format("templating-demo-group%d", count.index+1)}"
    }
  
    network {
        name = "${format("%s_%d", var.network_name, count.index+1)}",
    }
    
    depends_on = ["openstack_networking_subnet_v2.subnets"]
    
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
    /* associates the floating IP to the first instance */
    floating_ip = "${openstack_networking_floatingip_v2.floatip_1.address}"
    instance_id = "${openstack_compute_instance_v2.servers_1.*.id[0]}"
}