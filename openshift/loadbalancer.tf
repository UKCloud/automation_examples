resource "openstack_compute_floatingip_v2" "loadbalancer_ip" {
  pool = "${var.OS_INTERNET_NAME}"
}

resource "openstack_networking_port_v2" "port_1" {
  name           = "port_1"
  network_id     = "${openstack_networking_network_v2.dmz.id}"
  admin_state_up = "true"
  fixed_ip       {
    subnet_id =  "${openstack_networking_subnet_v2.dmz_subnet.id}"
    ip_address = "${cidrhost(var.DMZ_Subnet, 20)}"
  }
}

data "template_file" "loadbalancer_config" {
  template = "${file("files/init.tpl")}"
  count = "${var.openshift_loadbalancer}"

  vars {
    hostname = "${format("lb%02d", count.index + 1)}"
    fqdn     = "${format("lb%02d", count.index + 1)}.${var.domain_name}"
  }
}

data "template_file" "haproxy_config" {
  template = "${file("files/haproxy.cfg")}"

  vars {
    openshift_fqdn     = "${var.cluster_hostname}.${var.domain_name}"
    cert_path          = "/etc/haproxy/certs/example.com.pem"
    master_nodes       = "${join("\n", formatlist("    server %s %s:8443 check", openstack_compute_instance_v2.master.*.name, openstack_compute_instance_v2.master.*.access_ip_v4))}"
    worker_nodes       = "${join("\n", formatlist("    server %s %s:80 check", openstack_compute_instance_v2.node.*.name, openstack_compute_instance_v2.node.*.access_ip_v4))}"
    infa_host          = "${openstack_compute_instance_v2.infra_host.access_ip_v4}:80"
  }
}

resource "tls_private_key" "example" {
    algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
    key_algorithm = "${tls_private_key.example.algorithm}"
    private_key_pem = "${tls_private_key.example.private_key_pem}"

    # Certificate expires after 12 hours.
    validity_period_hours = 12

    # Generate a new certificate if Terraform is run within three
    # hours of the certificate's expiration time.
    early_renewal_hours = 3

    # Reasonable set of uses for a server SSL certificate.
    allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
    ]

    dns_names = ["${var.cluster_hostname}.${var.domain_name}", "*.${var.apps_domain_name}"]

    subject {
        common_name = "${var.cluster_hostname}.${var.domain_name}"
        organization = "ACME Examples, Inc"
    }
}

resource "openstack_compute_instance_v2" "loadbalancer" {
  name        = "${format("lb%02d", count.index + 1)}.${var.domain_name}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.haproxy_type}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.any_http.name}"]
  availability_zone = "${element(var.availability_zones, count.index)}"

  user_data = "${element(data.template_file.loadbalancer_config.*.rendered, count.index)}"

  depends_on = [ "openstack_compute_instance_v2.infra_host" ]
  count = "${var.openshift_loadbalancer}"

  network {
    name = "${openstack_networking_network_v2.dmz.name}"
  }

  connection {
    bastion_host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
    bastion_user = "centos"
    bastion_private_key = "${file(var.private_key_file)}"

    user = "centos"
    private_key = "${file(var.private_key_file)}"
  }

  provisioner "file" {
    content = "${tls_self_signed_cert.example.cert_pem}"
    destination = "/tmp/example.com.crt"
  }

  provisioner "file" {
    content = "${tls_private_key.example.private_key_pem}"
    destination = "/tmp/example.com.key"
  }

  provisioner "file" {
    content = "${data.template_file.haproxy_config.rendered}"
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp ~centos/.ssh/authorized_keys /root/.ssh",
      "sudo chmod -R go-rwx /root/.ssh",
      "sudo yum install -y NetworkManager epel-release",
      "sudo systemctl enable NetworkManager.service",
      "sudo systemctl start NetworkManager.service",
      "sudo yum -y install haproxy",
      "sudo mkdir -p /etc/haproxy/certs",
      "cat /tmp/example.com.crt /tmp/example.com.key | sudo tee /etc/haproxy/certs/example.com.pem",
      "sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo systemctl enable haproxy",
      "sudo systemctl start haproxy"
    ]
  }
  
}

# resource "null_resource" "loadbalancer" {
#   depends_on = [ "openstack_compute_instance_v2.loadbalancer", "openstack_compute_instance_v2.infra_host" ]

#   triggers {
#     instance_ids = "${join(",", openstack_compute_instance_v2.loadbalancer.*.id)}"
#   }

#   connection {
#     bastion_host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
#     bastion_user = "centos"
#     bastion_private_key = "${file(var.private_key_file)}"

#     host = "${element(openstack_compute_instance_v2.loadbalancer.*.address, count.index)}"
#     user = "centos"
#     private_key = "${file(var.private_key_file)}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "#sudo yum update -y --exclude=kernel"
#     ]
#   }
# }
