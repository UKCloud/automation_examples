variable "vcd_org" {}
variable "vcd_userid" {}
variable "vcd_pass" {}
variable "catalog" { default = "DevOps" }
variable "vapp_template" { default = "centos71" }
variable "edge_gateway" { default = "Edge Gateway Name" }
variable "jumpbox_ext_ip" { default = "51.179.193.252" }
variable "website_ip" { default = "51.179.193.253" }
variable "chef_organisation" { default = "skyscapecloud" }
variable "chef_userid" { default = "rcoward" }
variable "ssh_user" { default = "vagrant" }
variable "ssh_password" { default = "vagrant" }

variable "chef_client_version" { default = "12.6.0" }
variable "mgt_net_cidr" { default = "10.10.0.0/24" }
variable "web_net_cidr" { default = "10.30.0.0/24" }
variable "data_net_cidr" { default = "10.20.0.0/24" }
variable "jumpbox_int_ip" { default = "10.10.0.100" }
variable "database_int_ip" { default = "10.20.0.100" }
variable "haproxy_int_ip" { default = "10.30.0.10" }
variable "webserver_count" { default = 2 }
 
# Configure the VMware vCloud Director Provider
provider "vcd" {
    user            = "${var.vcd_userid}"
    org             = "${var.vcd_org}"
    url				= "https://api.vcd.portal.skyscapecloud.com/api"
    password        = "${var.vcd_pass}"
}

# Create our networks
resource "vcd_network" "mgt_net" {
    name = "Management Network"
    edge_gateway = "${var.edge_gateway}"
    gateway = "${cidrhost(var.mgt_net_cidr, 1)}"

    static_ip_pool {
        start_address = "${cidrhost(var.mgt_net_cidr, 10)}"
        end_address = "${cidrhost(var.mgt_net_cidr, 200)}"
    }
}

resource "vcd_network" "web_net" {
    name = "Webserver Network"
    edge_gateway = "${var.edge_gateway}"
    gateway = "${cidrhost(var.web_net_cidr, 1)}"

    static_ip_pool {
        start_address = "${cidrhost(var.web_net_cidr, 10)}"
        end_address = "${cidrhost(var.web_net_cidr, 200)}"
    }
}

resource "vcd_network" "data_net" {
    name = "Database Network"
    edge_gateway = "${var.edge_gateway}"
    gateway = "${cidrhost(var.data_net_cidr, 1)}"

    static_ip_pool {
        start_address = "${cidrhost(var.data_net_cidr, 10)}"
        end_address = "${cidrhost(var.data_net_cidr, 200)}"
    }
}

# Jumpbox VM on the Management Network
resource "vcd_vapp" "jumpbox" {
    name          = "jump01"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 512
    cpus          = 1
    network_name  = "${vcd_network.mgt_net.name}"
    ip            = "${var.jumpbox_int_ip}"

    depends_on    = [ "vcd_dnat.jumpbox-ssh", "vcd_firewall_rules.website-fw", "vcd_snat.website-outbound" ]

    connection {
        host = "${var.jumpbox_ext_ip}"
        user = "${var.ssh_user}"
        password = "${var.ssh_password}"
    }

    provisioner "chef"  {
        run_list = ["chef-client","chef-client::config","chef-client::delete_validation"]
        node_name = "${vcd_vapp.jumpbox.name}"
        server_url = "https://api.chef.io/organizations/${var.chef_organisation}"
        validation_client_name = "skyscapecloud-validator"
        validation_key = "${file("~/.chef/skyscapecloud-validator.pem")}"
        version = "${var.chef_client_version}"
    }
}

# Database VM on the Database network
resource "vcd_vapp" "database" {
    name          = "db01"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 2048
    cpus          = 2
    network_name  = "${vcd_network.data_net.name}"
    ip            = "${var.database_int_ip}"

    depends_on    = [ "vcd_vapp.jumpbox", "vcd_snat.website-outbound" ]

    connection {
        bastion_host = "${var.jumpbox_ext_ip}"
        bastion_user = "${var.ssh_user}"
        bastion_password = "${var.ssh_password}"

        host = "${var.database_int_ip}"
        user = "${var.ssh_user}"
        password = "${var.ssh_password}"
    }

    provisioner "chef"  {
        run_list = [ "chef-client", "chef-client::config", "chef-client::delete_validation", "my_web_app::db_setup" ]
        node_name = "${vcd_vapp.database.name}"
        server_url = "https://api.chef.io/organizations/${var.chef_organisation}"
        validation_client_name = "${var.chef_organisation}-validator"
        validation_key = "${file("~/.chef/${var.chef_organisation}-validator.pem")}"
        version = "${var.chef_client_version}"
        attributes {
            "tags" = [ "dbserver" ]
        }
    }    
}

# Load-balancer VM on the Webserver network
resource "vcd_vapp" "haproxy" {
    name          = "lb01"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 1024
    cpus          = 1

    network_name  = "${vcd_network.web_net.name}"
    ip            = "${var.haproxy_int_ip}"

    depends_on    = [ "vcd_vapp.jumpbox", "vcd_vapp.webservers", "vcd_dnat.loadbalance-http", "vcd_dnat.loadbalancer-stats", "vcd_snat.website-outbound" ]

    provisioner "chef"  {
        run_list = [ "chef-client", "chef-client::config", "chef-client::delete_validation", "my_web_app::load_balancer" ]
        node_name = "${vcd_vapp.haproxy.name}"
        server_url = "https://api.chef.io/organizations/${var.chef_organisation}"
        validation_client_name = "${var.chef_organisation}-validator"
        validation_key = "${file("~/.chef/${var.chef_organisation}-validator.pem")}"
        version = "${var.chef_client_version}"
        connection {
            bastion_host = "${var.jumpbox_ext_ip}"
            bastion_user = "${var.ssh_user}"
            bastion_password = "${var.ssh_password}"

            host = "${var.haproxy_int_ip}"
            user = "${var.ssh_user}"
            password = "${var.ssh_password}"
        }
    }        
}

# Webserver VMs on the Webserver network
resource "vcd_vapp" "webservers" {
    name          = "${format("web%02d", count.index + 1)}"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 1024
    cpus          = 1
    network_name  = "${vcd_network.web_net.name}"
    ip            = "${cidrhost(var.web_net_cidr, count.index + 100)}"

    count         = "${var.webserver_count}"

    depends_on    = [ "vcd_vapp.database", "vcd_vapp.jumpbox", "vcd_snat.website-outbound" ]

    connection {
        bastion_host = "${var.jumpbox_ext_ip}"
        bastion_user = "${var.ssh_user}"
        bastion_password = "${var.ssh_password}"

        host = "${cidrhost(var.web_net_cidr, count.index + 100)}"
        user = "${var.ssh_user}"
        password = "${var.ssh_password}"
    }

    provisioner "chef"  {
        run_list = [ "chef-client", "chef-client::config", "chef-client::delete_validation", "my_web_app" ]
        node_name = "${format("web%02d", count.index + 1)}"
        server_url = "https://api.chef.io/organizations/${var.chef_organisation}"
        validation_client_name = "${var.chef_organisation}-validator"
        validation_key = "${file("~/.chef/${var.chef_organisation}-validator.pem")}"
        version = "${var.chef_client_version}"
        attributes {
            "tags" = [ "webserver" ]
        }
    }            
}

# Inbound SSH to the Jumpbox server
resource "vcd_dnat" "jumpbox-ssh" {
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.jumpbox_ext_ip}"
    port          = 22
    internal_ip   = "${var.jumpbox_int_ip}"
}

# Inbound HTTP to the loadbalancer server
resource "vcd_dnat" "loadbalance-http" {
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.website_ip}"
    port          = 80
    internal_ip   = "${var.haproxy_int_ip}"
}

resource "vcd_dnat" "loadbalancer-stats" {
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.website_ip}"
    port          = 8080
    internal_ip   = "${var.haproxy_int_ip}"
}

# SNAT Outbound traffic
resource "vcd_snat" "website-outbound" {
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.website_ip}"
    internal_ip   = "10.0.0.0/8"
}

resource "vcd_firewall_rules" "website-fw" {
    edge_gateway   = "${var.edge_gateway}"
    default_action = "drop"

    depends_on     = [ "vcd_network.mgt_net", "vcd_network.data_net", "vcd_network.web_net" ]

    rule {
        description      = "allow-jumpbox-ssh"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "22"
        destination_ip   = "${var.jumpbox_ext_ip}"
        source_port      = "any"
        source_ip        = "any"
    }

    rule {
        description      = "allow-loadbalancer-http"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "80"
        destination_ip   = "${var.website_ip}"
        source_port      = "any"
        source_ip        = "any"
    }

    rule {
        description      = "allow-loadbalancer-stats"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "1936"
        destination_ip   = "${var.website_ip}"
        source_port      = "any"
        source_ip        = "any"
    }

    rule {
        description      = "allow-loadbalancer-stats2"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "8080"
        destination_ip   = "${var.website_ip}"
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
        source_ip        = "10.0.0.0/8"
    }

    rule {
        description      = "allow-internal"
        policy           = "allow"
        protocol         = "any"
        destination_port = "any"
        destination_ip   = "10.0.0.0/8"
        source_port      = "any"
        source_ip        = "10.0.0.0/8"
    }
}
