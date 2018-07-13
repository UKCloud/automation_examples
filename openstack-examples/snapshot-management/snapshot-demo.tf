provider "openstack" {
	cloud = "demo-frn"    
    insecure = true
}

# define resource for public network

# provision a floating IP
resource "openstack_compute_floatingip_v2" "floatip_1" {
  pool = "internet"
}

# Key for accessing server

resource "openstack_compute_keypair_v2" "snapshot-demo-keypair" {
  name       = "snapshot-demo-keypair"
  public_key = "${var.SSH_KEY}"
  region = "regionOne"
  
}

# create network + subnet dmz
resource "openstack_networking_network_v2" "dmz" {
    name = "dmz"
    admin_state_up = "true"
    region = "regionOne"
}

resource "openstack_networking_subnet_v2" "subnet-dmz" {
    name = "subnet-dmz"
    network_id = "${openstack_networking_network_v2.dmz.id}"
    cidr = "192.168.11.0/24"
    region = "regionOne"    
}


# create a router, attached to all networks

resource "openstack_networking_router_v2" "frn-net-router" {
  name             = "frn-net-router"
  /*external_network_id = "${openstack_networking_network_v2.internet.id}"*/
  external_network_id = "df08c5c8-1242-4c62-ae1a-b0db5ef49f74"
  region = "regionOne"
}

# interface for dmz

resource "openstack_networking_router_interface_v2" "router_interface_subnet-dmz" {
  router_id = "${openstack_networking_router_v2.frn-net-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet-dmz.id}"
  region = "regionOne"
}

# add the compute node

resource "openstack_compute_instance_v2" "frn-server-dmz" {
    name = "frn-server-dmz"
    image_name = "Centos 7 - LTS"
    flavor_name = "t1.tiny"
    network {
        name = "dmz"
    }
    security_groups = ["default"]
    region = "regionOne"
    key_pair = "snapshot-demo-keypair"
    
}

resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = "${openstack_compute_instance_v2.frn-server-dmz.id}"
  volume_id = "${openstack_blockstorage_volume_v2.snapvol_1.id}"
  region = "regionOne"
}


# assign the floating IP

resource "openstack_compute_floatingip_associate_v2" "frn-ip-assoc" {
    floating_ip = "${openstack_compute_floatingip_v2.floatip_1.address}"   
    instance_id = "${openstack_compute_instance_v2.frn-server-dmz.id}"
    region = "regionOne"
}


# create a volume

resource "openstack_blockstorage_volume_v2" "snapvol_1" {
  name        = "snapvol_1"
  description = "Snapshot Demo Volume"
  size        = 1
  region = "regionOne"
}

