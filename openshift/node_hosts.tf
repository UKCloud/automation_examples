resource "openstack_compute_servergroup_v2" "node" {
  name = "node-servergroup"
  policies = ["anti-affinity"]
}

data "template_file" "node_config" {
  template = "${file("files/init.tpl")}"
  count = "${var.openshift_nodes}"

  vars {
    hostname = "${format("node%02d", count.index + 1)}"
    fqdn     = "${format("node%02d", count.index + 1)}.${var.domain_name}"
  }
}

resource "openstack_compute_instance_v2" "node" {
  name        = "${format("node%02d", count.index + 1)}.${var.domain_name}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.node_type}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.openshift_network.name}",
                     "${openstack_networking_secgroup_v2.openshift_endpoints.name}",
                     ]
  availability_zone = "${element(var.availability_zones, count.index)}"

  user_data = "${element(data.template_file.node_config.*.rendered, count.index)}"

  depends_on = [ "openstack_compute_instance_v2.infra_host" ]
  count = "${var.openshift_nodes}"
  scheduler_hints = { group = "${openstack_compute_servergroup_v2.node.id}" }

  network {
    name = "${openstack_networking_network_v2.openshift.name}"
  }
  
  metadata {
    zone = "${element(var.availability_zones, count.index)}"
  }

  connection {
    bastion_host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
    bastion_user = "centos"
    bastion_private_key = "${file(var.private_key_file)}"

    user = "centos"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp ~centos/.ssh/authorized_keys /root/.ssh",
      "sudo chmod -R go-rwx /root/.ssh",
      "echo SuperSecret | sudo passwd centos --stdin",
      "sudo yum install -y NetworkManager epel-release",
      "sudo systemctl enable NetworkManager.service",
      "sudo systemctl start NetworkManager.service"
    ]
  }

}

# resource "null_resource" "node" {
#   depends_on = [ "openstack_compute_instance_v2.infra_host", "openstack_compute_instance_v2.node" ]
#   count = "${var.openshift_nodes}"

#   triggers {
#     instance_ids = "${join(",", openstack_compute_instance_v2.node.*.id)}"
#   }

#   connection {
#     bastion_host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
#     bastion_user = "centos"
#     bastion_private_key = "${file(var.private_key_file)}"

#     host = "${element(openstack_compute_instance_v2.node.*.address, count.index)}"
#     user = "centos"
#     private_key = "${file(var.private_key_file)}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "#sudo yum update -y --exclude=kernel",
#     ]
#   }
# }