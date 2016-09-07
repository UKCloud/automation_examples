data "template_file" "schema_sql" {
    template = "${file("powerdns/schema.sql")}"

    vars {
        mysql_password = "${var.mysql_powerdns_password}"
        domain_name    = "${var.domain_name}"
        dns_server     = "${cidrhost(var.Management_Subnet, 5)}"
    }
}

data "template_file" "pdns_conf" {
    template = "${file("powerdns/pdns.conf")}"

    vars {
        mysql_password = "${var.mysql_powerdns_password}"
        api_key = "${var.powerdns_api_key}"
    }
}

resource "openstack_compute_floatingip_v2" "infra_host_ip" {
  region = ""
  pool = "${lookup(var.OS_INTERNET_NAME, var.PLATFORM)}"
}

resource "openstack_compute_instance_v2" "infra_host" {
  name        = "infra01.${var.domain_name}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.infra_type}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.infra_host.name}"]

  network {
    name = "${openstack_networking_network_v2.management.name}"
    fixed_ip_v4 = "${cidrhost(var.Management_Subnet, 5)}"
    floating_ip = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
  }

  connection {
    user = "centos"
    private_key = "${file(var.private_key_file)}"
    host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp ~centos/.ssh/authorized_keys /root/.ssh",
      "sudo chmod -R go-rwx /root/.ssh",
      "echo 'nameserver 8.8.8.8' > /tmp/resolv.conf",
      "sudo mv /etc/resolv.conf /etc/resolv.conf.orig",
      "sudo cp /tmp/resolv.conf /etc/resolv.conf",
      "sudo yum -y install epel-release yum-plugin-priorities",
      "sudo curl -o /etc/yum.repos.d/powerdns-auth-40.repo https://repo.powerdns.com/repo-files/centos-auth-40.repo",
      "sudo yum update -y --exclude=kernel",
      "sudo yum -y install git ansible mariadb-server mariadb pdns pdns-backend-mysql bind-utils pyOpenSSL",
      "sudo systemctl enable mariadb.service",
      "sudo systemctl start mariadb.service",
      "sudo git clone https://github.com/openshift/openshift-ansible.git /root/openshift-ansible"
    ]
  }

  provisioner "file" {
    content = "${data.template_file.schema_sql.rendered}"
    destination = "/tmp/powerdns_schema.sql"
  }

  provisioner "file" {
    content = "${data.template_file.pdns_conf.rendered}"
    destination = "/tmp/pdns.conf"
  }

  provisioner "file" {
    content = "${file(var.private_key_file)}"
    destination = "/tmp/root_id_rsa"
  }

  provisioner "file" {
    content = "${file(var.public_key_file)}"
    destination = "/tmp/root_id_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/root_id_rsa /root/.ssh/id_rsa",
      "sudo mv /tmp/root_id_rsa.pub /root/.ssh/id_rsa.pub",
      "sudo chown root.root /root/.ssh/id_rsa /root/.ssh/id_rsa.pub",
      "sudo chmod go-rwx /root/.ssh/id_rsa /root/.ssh/id_rsa.pub",
      "cat /tmp/powerdns_schema.sql | sudo mysql",
      "sudo cp /tmp/pdns.conf /etc/pdns/pdns.conf",
      "sudo systemctl enable pdns.service",
      "sudo systemctl start pdns.service",
      "sudo cp /etc/resolv.conf.orig /etc/resolv.conf"
    ]
  }
}

resource "openstack_networking_secgroup_v2" "infra_host" {
  name = "Infrastructure Host Access"
  description = "Allow access to Infrastructure VM"
}

resource "openstack_networking_secgroup_rule_v2" "infra_host_rule_ssh" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.infra_host.id}"
}

resource "openstack_networking_secgroup_rule_v2" "infra_host_rule_dns" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  port_range_min = 53
  port_range_max = 53
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.infra_host.id}"
}
