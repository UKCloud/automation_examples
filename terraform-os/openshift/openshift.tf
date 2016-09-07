# Now all the servers are up, lets use ansible to deploy openshift

data "template_file" "ansible_hosts" {
  template = "${file("ansible_hosts.tpl")}"

  vars {
    master_ipaddress = "${join("\n", openstack_compute_instance_v2.master.*.name)}"
    master_nodes = "${join("\n", formatlist("%s openshift_node_labels=\"{'region': 'infra', 'zone': 'default', 'router': 'router'}\"", openstack_compute_instance_v2.master.*.name))}"
    compute_nodes = "${join("\n", formatlist("%s openshift_node_labels=\"{'region': '%s', 'zone': '%s'}\"", openstack_compute_instance_v2.node.*.name, "cor0005", "nova"))}"
    domain_name = "${var.domain_name}"
    etcd_ipaddress = "${join("\n", openstack_compute_instance_v2.etcd.*.name)}"
    loadbalancer_ipaddress = "${openstack_compute_instance_v2.loadbalancer.name}"
  }
}

resource "null_resource" "deploy_openshift" {
  depends_on = [ "openstack_compute_instance_v2.infra_host" ]

  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", openstack_compute_instance_v2.master.*.id)},${join(",", openstack_compute_instance_v2.node.*.id)},${join(",", openstack_compute_instance_v2.etcd.*.id)},${openstack_compute_instance_v2.loadbalancer.id},${openstack_compute_instance_v2.infra_host.id}"
  }


  connection {
    user = "root"
    private_key = "${file(var.private_key_file)}"
    host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
  }

  provisioner "file" {
    content = "${data.template_file.ansible_hosts.rendered}"
    destination = "/etc/ansible/hosts"
  }

  provisioner "file" {
    content = "${join("\n", formatlist("DELETE FROM records WHERE domain_id='1' AND name='%s'; INSERT INTO records (domain_id, name, content, type,ttl,prio) VALUES (1,'%s','%s','A',120,NULL);", openstack_compute_instance_v2.master.*.name, openstack_compute_instance_v2.master.*.name, openstack_compute_instance_v2.master.*.access_ip_v4))}"
    destination = "/tmp/dns_master_nodes.sql"
  }

  provisioner "file" {
    content = "${join("\n", formatlist("DELETE FROM records WHERE domain_id='1' AND name='%s'; INSERT INTO records (domain_id, name, content, type,ttl,prio) VALUES (1,'%s','%s','A',120,NULL);", openstack_compute_instance_v2.node.*.name, openstack_compute_instance_v2.node.*.name, openstack_compute_instance_v2.node.*.access_ip_v4))}"
    destination = "/tmp/dns_compute_nodes.sql"
  }

  provisioner "file" {
    content = "${join("\n", formatlist("DELETE FROM records WHERE domain_id='1' AND name='%s'; INSERT INTO records (domain_id, name, content, type,ttl,prio) VALUES (1,'%s','%s','A',120,NULL);", openstack_compute_instance_v2.etcd.*.name, openstack_compute_instance_v2.etcd.*.name, openstack_compute_instance_v2.etcd.*.access_ip_v4))}"
    destination = "/tmp/dns_etcd_nodes.sql"
  }

  provisioner "file" {
    content = "${join("\n", formatlist("DELETE FROM records WHERE domain_id='1' AND name='%s'; INSERT INTO records (domain_id, name, content, type,ttl,prio) VALUES (1,'%s','%s','A',120,NULL);", list(openstack_compute_instance_v2.loadbalancer.name, "openshift.${var.domain_name}"), list(openstack_compute_instance_v2.loadbalancer.name, "openshift.${var.domain_name}"), list(openstack_compute_instance_v2.loadbalancer.access_ip_v4, openstack_compute_instance_v2.loadbalancer.access_ip_v4)))}"
    destination = "/tmp/dns_haproxy_nodes.sql"
  }

  provisioner "file" {
    content = "${join("\n", formatlist("ssh -o 'StrictHostKeyChecking no' %s@%s sudo systemctl status NetworkManager.service", "centos", concat(openstack_compute_instance_v2.master.*.name, openstack_compute_instance_v2.node.*.name, openstack_compute_instance_v2.etcd.*.name, list(openstack_compute_instance_v2.loadbalancer.name))))}"
    destination = "/tmp/pre-cache-ssh-known-hosts.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/dns_master_nodes.sql | sudo mysql powerdns",
      "cat /tmp/dns_compute_nodes.sql | sudo mysql powerdns",
      "cat /tmp/dns_etcd_nodes.sql | sudo mysql powerdns",
      "cat /tmp/dns_haproxy_nodes.sql | sudo mysql powerdns",
      "rm -f /root/.ssh/known_hosts",
      "chmod +x /tmp/pre-cache-ssh-known-hosts.sh; /tmp/pre-cache-ssh-known-hosts.sh",
      "ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml"
    ]
  }

}
