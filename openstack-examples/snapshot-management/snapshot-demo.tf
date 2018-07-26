provider "openstack" {
	cloud = "demo-cor"
    insecure = false
}

data "openstack_networking_network_v2" "internet" {
  name = "internet"
}

data "openstack_images_image_v2" "centos" {
  name =  "centos72"
  most_recent = true
  # min_size = 20
}

data "openstack_images_image_v2" "win2012" {
	name = "windows-2012r2-LTS"
	# min_size = 60
}

# define resource for public network

# provision a floating IP
resource "openstack_compute_floatingip_v2" "floatip_snap" {
  pool = "internet"
}

# Key for accessing server

resource "openstack_compute_keypair_v2" "snapshot-demo-key" {
  name       = "snapshot-demo-key"
  public_key = "${file("snapshot-demo-key.pub")}"
  region = "regionOne"
}

# create network + subnet dmz
resource "openstack_networking_network_v2" "net_snap" {
    name = "net_snap"
    admin_state_up = "true"
    region = "regionOne"
}

resource "openstack_networking_subnet_v2" "subnet_snap" {
    name = "subnet_snap"
    network_id = "${openstack_networking_network_v2.net_snap.id}"
    cidr = "192.168.11.0/24"
    region = "regionOne"
    dns_nameservers = ["8.8.4.4", "8.8.8.8"]
}

# create a router, attached to all networks

resource "openstack_networking_router_v2" "router_snap" {
  name             = "router_snap"
  external_network_id = "${data.openstack_networking_network_v2.internet.id}"
  region = "regionOne"
}

# interface for dmz

# assign the floating IP

resource "openstack_compute_floatingip_associate_v2" "assoc_snap" {
    floating_ip = "${openstack_compute_floatingip_v2.floatip_snap.address}"
    instance_id = "${openstack_compute_instance_v2.server_snap.id}"
    region = "regionOne"
    wait_until_associated = true
}



resource "openstack_networking_router_interface_v2" "router_interface_subnet_snap" {
  router_id = "${openstack_networking_router_v2.router_snap.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_snap.id}"
  region = "regionOne"
}

# add the compute node

resource "openstack_compute_instance_v2" "server_snap" {

    name = "server_snap"
    flavor_name = "t1.tiny"

    network {
        name = "net_snap"
    }

    security_groups = ["default"]
    region = "regionOne"
    key_pair = "snapshot-demo-key"
	admin_pass = "myPassIsGreat1"
    # depends_on = ["openstack_networking_subnet_v2.subnet_snap"]
    depends_on = ["openstack_networking_subnet_v2.subnet_snap", "openstack_blockstorage_volume_v2.bootvol_snap"]

    block_device {
      /*uuid                  = "${data.openstack_images_image_v2.centos.id}"*/
      uuid                  = "${openstack_blockstorage_volume_v2.bootvol_snap.id}"
      source_type           = "volume"
      destination_type      = "volume"
      volume_size           = 20
      boot_index            = 0
      delete_on_termination = true
    }

    block_device {
      source_type           = "blank"
      boot_index            = 1
      destination_type      = "volume"
      delete_on_termination = true
      volume_size           = 20
    }

    connection {
      user        = "centos"
      host        = "${openstack_compute_floatingip_v2.floatip_1.address}"
      private_key = "${file("snapshot-demo-key")}"
    }

    metadata = {
        groups = "snapshot_demo"
    }
}

/*resource "openstack_compute_volume_attach_v2" "attach_snap" {
  instance_id = "${openstack_compute_instance_v2.server_snap.id}"
  volume_id = "${openstack_blockstorage_volume_v2.volume_snap.id}"
  region = "regionOne"
}*/

# create a volume

resource "openstack_blockstorage_volume_v2" "bootvol_snap" {
  name        = "bootvol_snap"
  description = "Snapshot Demo Volume"
  size        = 60
  region = "regionOne"
  #  image_id = "${data.openstack_images_image_v2.centos.id}"
  image_id = "${data.openstack_images_image_v2.win2012.id}"
  volume_type = "TIER2"
}


output "bootvol_snap_id" {
    value = "${openstack_blockstorage_volume_v2.bootvol_snap.id}"
}

output "admin_password" {
	value = "${openstack_compute_instance_v2.server_snap.admin_pass}"
}
