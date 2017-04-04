resource "openstack_compute_servergroup_v2" "master" {
  name = "master-servergroup"
  policies = ["anti-affinity"]
}

data "template_file" "master_config" {
  template = "${file("files/init.tpl")}"
  count = "${var.openshift_masters}"

  vars {
    hostname = "${format("master%02d", count.index + 1)}"
    fqdn     = "${format("master%02d", count.index + 1)}.${var.domain_name}"
  }
}

resource "openstack_compute_instance_v2" "master" {
  name        = "${format("master%02d", count.index + 1)}.${var.domain_name}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.master_type}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.openshift_network.name}",
                     "${openstack_networking_secgroup_v2.openshift_endpoints.name}",
                     ]
  availability_zone = "${element(var.availability_zones, count.index)}"

  user_data = "${element(data.template_file.master_config.*.rendered, count.index)}"
  count = "${var.openshift_masters}"

  depends_on = [ "openstack_compute_instance_v2.infra_host" ]
  scheduler_hints = { group = "${openstack_compute_servergroup_v2.master.id}" }

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

    # host = "${element(openstack_compute_instance_v2.master.*.address, count.index)}"
    user = "centos"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp ~centos/.ssh/authorized_keys /root/.ssh",
      "sudo chmod -R go-rwx /root/.ssh",
      "sudo yum install -y NetworkManager epel-release",
      "sudo systemctl enable NetworkManager.service",
      "sudo systemctl start NetworkManager.service"
    ]
  }
}

# resource "null_resource" "master" {
#   depends_on = [ "openstack_compute_instance_v2.infra_host", "openstack_compute_instance_v2.master" ]
#   count = "${var.openshift_masters}"

#   triggers {
#     instance_ids = "${join(",", openstack_compute_instance_v2.master.*.id)}"
#   }

#   connection {
#     bastion_host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
#     bastion_user = "centos"
#     bastion_private_key = "${file(var.private_key_file)}"

#     host = "${element(openstack_compute_instance_v2.master.*.address, count.index)}"
#     user = "centos"
#     private_key = "${file(var.private_key_file)}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "#sudo yum update -y --exclude=kernel",
#     ]
#   }
# }