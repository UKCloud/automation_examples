variable "vcd_org" {}
variable "vcd_userid" {}
variable "vcd_pass" {}
variable "webserver_count" { default = 2 }
variable "jumpbox_ext_ip" { default = "51.179.193.252" }
 
# Configure the VMware vCloud Director Provider
provider "vcd" {
    user            = "${var.vcd_userid}"
    org             = "${var.vcd_org}"
    url				= "https://api.vcd.portal.skyscapecloud.com/api"
    password        = "${var.vcd_pass}"
}

# Create a new network
resource "vcd_network" "demo_net" {
    name = "demo_net"
    edge_gateway = "Edge Gateway Name"
    gateway = "10.10.0.1"

    static_ip_pool {
        start_address = "10.10.0.152"
        end_address = "10.10.0.254"
    }

    dhcp_pool {
        start_address = "10.10.0.2"
        end_address = "10.10.0.100"
    }
}

resource "vcd_vapp" "jumpbox" {
    name          = "jump01"
    catalog_name  = "DevOps"
    template_name = "centos71"
    memory        = 512
    cpus          = 1

    network_name  = "${vcd_network.demo_net.name}"
    ip = "10.10.0.152"
}

resource "vcd_vapp" "database" {
    name          = "db01"
    catalog_name  = "DevOps"
    template_name = "centos71"
    memory        = 2048
    cpus          = 2

    network_name  = "${vcd_network.demo_net.name}"
    ip = "10.10.0.153"
}

resource "vcd_vapp" "webservers" {
    name          = "${format("web%02d", count.index + 1)}"
    catalog_name  = "DevOps"
    template_name = "centos71"
    memory        = 1024
    cpus          = 1

    count         = "${var.webserver_count}"

    network_name  = "${vcd_network.demo_net.name}"
}

resource "vcd_dnat" "jumpbox-ssh" {
    edge_gateway  = "Edge Gateway Name"
    external_ip   = "${var.jumpbox_ext_ip}"
    port          = 22
    internal_ip   = "${vcd_vapp.jumpbox.ip}"
}

resource "vcd_firewall_rules" "demo-fw" {
    edge_gateway   = "Edge Gateway Name"
    default_action = "drop"

    rule {
        description      = "allow-jumpbox-ssh"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "22"
        destination_ip   = "${vcd_dnat.jumpbox-ssh.external_ip}"
        source_port      = "any"
        source_ip        = "any"
    }

    rule {
        description      = "allow-outbound"
        policy           = "allow"
        protocol         = "any"
        destination_port = "any"
        destination_ip   = "any"
        source_port      = "any"
        source_ip        = "10.10.0.0/24"
    }

}
