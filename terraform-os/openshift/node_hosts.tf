resource "openstack_compute_servergroup_v2" "node" {
  name = "node-servergroup"
  policies = ["anti-affinity"]
}

resource "openstack_compute_instance_v2" "node" {
  name        = "${format("node%02d", count.index + 1)}.${var.domain_name}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.node_type}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.openshift_network.name}"]

  depends_on = [ "openstack_compute_instance_v2.infra_host" ]
  scheduler_hints = { group = "${openstack_compute_servergroup_v2.node.id}" }

  network {
    name = "${openstack_networking_network_v2.openshift.name}"
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
      "sudo yum update -y --exclude=kernel",
      "sudo yum install -y NetworkManager epel-release",
      "sudo systemctl enable NetworkManager.service",
      "sudo systemctl start NetworkManager.service"
    ]
  }

  count = "${var.openshift_nodes}"
}
