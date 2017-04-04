# User-data script to pass to cloud-init
data "template_file" "infra_config" {
  template = "${file("files/init.tpl")}"
  
  vars {
    hostname = "infra01"
    fqdn     = "infra01.${var.domain_name}"
  }
}

data "template_file" "schema_sql" {
    template = "${file("files/powerdns/schema.sql")}"

    vars {
        mysql_password = "${var.mysql_powerdns_password}"
        domain_name    = "${var.domain_name}"
        dns_server     = "${cidrhost(var.DMZ_Subnet, 5)}"
    }
}

data "template_file" "pdns_conf" {
    template = "${file("files/powerdns/pdns.conf")}"

    vars {
        mysql_password = "${var.mysql_powerdns_password}"
        api_key = "${var.powerdns_api_key}"
    }
}

resource "openstack_compute_floatingip_v2" "infra_host_ip" {
  pool = "${var.OS_INTERNET_NAME}"
}

resource "openstack_compute_instance_v2" "infra_host" {
  name        = "infra01.${var.domain_name}"
  image_name  = "${var.IMAGE_NAME}"
  flavor_name = "${var.infra_type}"
  key_pair    = "${openstack_compute_keypair_v2.ssh-keypair.name}"
  security_groups = ["${openstack_networking_secgroup_v2.any_ssh.name}",
                     "${openstack_networking_secgroup_v2.local_ssh.name}",
                     "${openstack_networking_secgroup_v2.local_dns.name}"
  ]
  availability_zone = "${element(var.availability_zones, 0)}"

  user_data = "${data.template_file.infra_config.rendered}"

  network {
    name = "${openstack_networking_network_v2.dmz.name}"
    fixed_ip_v4 = "${cidrhost(var.DMZ_Subnet, 5)}"
    floating_ip = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
  }

  connection {
    user = "centos"
    private_key = "${file(var.private_key_file)}"
    host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
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

  provisioner "file" {
    source = "files/setup-powerdns.sh"
    destination = "/tmp/setup-powerdns.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/setup-powerdns.sh",
      "sudo /tmp/setup-powerdns.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp ~centos/.ssh/authorized_keys /root/.ssh",
      "sudo mv /tmp/root_id_rsa /root/.ssh/id_rsa",
      "sudo mv /tmp/root_id_rsa.pub /root/.ssh/id_rsa.pub",
      "sudo chown root.root /root/.ssh/id_rsa /root/.ssh/id_rsa.pub",
      "sudo chmod -R go-rwx /root/.ssh",

      "sudo yum -y install git python2-pip pyOpenSSL python-devel openssl-devel",
      "sudo yum -y groupinstall 'Development Tools'",
      "sudo pip install ansible==2.2.0.0 --upgrade",
      "sudo git clone --branch ${var.openshift_version} https://github.com/openshift/openshift-ansible.git /root/openshift-ansible"
   ]
  }
}

# resource "null_resource" "infra_host" {
#   depends_on = [ "openstack_compute_instance_v2.infra_host" ]

#   triggers {
#     instance_ids = "${openstack_compute_instance_v2.infra_host.id}"
#   }
    
#   connection {
#     user = "centos"
#     private_key = "${file(var.private_key_file)}"
#     host = "${openstack_compute_floatingip_v2.infra_host_ip.address}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "#sudo yum update -y --exclude=kernel",
#    ]
#   }
# }