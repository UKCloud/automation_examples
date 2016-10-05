# Now all the servers are up, lets use ansible to deploy openshift

data "template_file" "ansible_hosts" {
  template = "${file(var.ansible_hosts_file)}"

  vars {
    master_ipaddress = "${join("\n", openstack_compute_instance_v2.master.*.name)}"
    master_nodes = "${join("\n", formatlist("%s openshift_hostname=%s openshift_node_labels=\"{'region': 'infra', 'zone': 'default', 'router': 'router'}\" openshift_schedulable=true", openstack_compute_instance_v2.master.*.name, openstack_compute_instance_v2.master.*.name))}"
    compute_nodes = "${join("\n", formatlist("%s openshift_node_labels=\"{'region': '%s', 'zone': '%s'}\"", openstack_compute_instance_v2.node.*.name, "cor0005", "nova"))}"
    cluster_hostname = "${var.cluster_hostname}"
    domain_name = "${var.domain_name}"
    app_subdomain = "${var.app_subdomain}"
    etcd_ipaddress = "${join("\n", openstack_compute_instance_v2.etcd.*.name)}"
    loadbalancer_ipaddress = "${join("\n", concat(openstack_compute_instance_v2.loadbalancer.*.name, list("")))}"
    OS_AUTH_URL = "${lookup(var.OS_AUTH_URL, var.PLATFORM)}"
    OS_USERNAME = "${var.OS_USERNAME}"
    OS_PASSWORD = "${var.OS_PASSWORD}"
    OS_TENANT_ID = "${var.OS_TENANT_ID}"
    OS_TENANT_NAME = "${var.OS_TENANT_NAME}"
    OS_REGION = "${var.OS_REGION}"
  }
}

data "template_file" "dns_entries" {
	template = "${file("powerdns/dns_entries.sql")}"
	
	vars {
		delete = "${join("\n", formatlist("DELETE FROM records WHERE domain_id='1' AND name='%s';", 
					concat(openstack_compute_instance_v2.master.*.name,
							openstack_compute_instance_v2.node.*.name,
							openstack_compute_instance_v2.etcd.*.name,
							openstack_compute_instance_v2.loadbalancer.*.name)))}"
		insert = "${join("\n", formatlist("INSERT INTO records (domain_id, name, content, type,ttl,prio) VALUES (1,'%s','%s','A',120,NULL);",
					concat(openstack_compute_instance_v2.master.*.name,
							openstack_compute_instance_v2.node.*.name,
							openstack_compute_instance_v2.etcd.*.name,
							openstack_compute_instance_v2.loadbalancer.*.name),
					concat(openstack_compute_instance_v2.master.*.access_ip_v4,
							openstack_compute_instance_v2.node.*.access_ip_v4,
							openstack_compute_instance_v2.etcd.*.access_ip_v4,
							openstack_compute_instance_v2.loadbalancer.*.access_ip_v4)))}"		
                cluster_fqdn     = "${var.cluster_hostname}.${var.domain_name}"
                cluster_address  = "${element(concat(openstack_compute_instance_v2.loadbalancer.*.access_ip_v4, openstack_compute_instance_v2.master.*.access_ip_v4), 0)}"
	}
}

resource "null_resource" "deploy_openshift" {
  depends_on = [ "openstack_compute_instance_v2.infra_host" ]

  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", openstack_compute_instance_v2.master.*.id)},${join(",", openstack_compute_instance_v2.node.*.id)},${join(",", openstack_compute_instance_v2.etcd.*.id)},${join(",", openstack_compute_instance_v2.loadbalancer.*.id)},${openstack_compute_instance_v2.infra_host.id}"
    openshift_config = "${data.template_file.ansible_hosts.rendered}"
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
    content = "${data.template_file.dns_entries.rendered}"
    destination = "/tmp/dns_entries.sql"
  }

  provisioner "file" {
    content = "${join("\n", formatlist("ssh -o 'StrictHostKeyChecking no' %s@%s sudo systemctl status NetworkManager.service", "centos", 
										concat(openstack_compute_instance_v2.master.*.name, 
											   openstack_compute_instance_v2.node.*.name, 
											   openstack_compute_instance_v2.etcd.*.name, 
											   openstack_compute_instance_v2.loadbalancer.*.name)))}"
    destination = "/tmp/pre-cache-ssh-known-hosts.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/dns_entries.sql | sudo mysql powerdns",
      "rm -f /root/.ssh/known_hosts",
      "chmod +x /tmp/pre-cache-ssh-known-hosts.sh; /tmp/pre-cache-ssh-known-hosts.sh",
      "ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml"
    ]
  }

}
