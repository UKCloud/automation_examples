variable "vcd_org" {}
variable "vcd_userid" {}
variable "vcd_pass" {}
variable "catalog" { default = "DevOps" }
variable "vapp_template" { default = "centos71" }
variable "edge_gateway" { default = "Edge Gateway Name" }
variable "jenkins_ext_ip" { default = "51.179.193.254" }

variable "chef_organisation" { default = "skyscapecloud" }
variable "chef_userid" { default = "rcoward" }
variable "ssh_user" { default = "vagrant" }
variable "ssh_password" { default = "vagrant" }

variable "github_oauth_userid" { default = "e8e55e2041f6f94fa3f3" }
variable "github_oauth_secret" { default = "a07c8806a30ccb1a54168586ab5ef8517f65d4e5" }

variable "chef_client_version" { default = "12.6.0" }
variable "dev_net_cidr" { default = "10.40.0.0/24" }

variable "jenkins_int_ip" { default = "10.40.0.100" }
 
# Configure the VMware vCloud Director Provider
provider "vcd" {
    user            = "${var.vcd_userid}"
    org             = "${var.vcd_org}"
    url				= "https://api.vcd.portal.skyscapecloud.com/api"
    password        = "${var.vcd_pass}"
}

# Create our networks
resource "vcd_network" "dev_net" {
    name = "Development Network"
    edge_gateway = "${var.edge_gateway}"
    gateway = "${cidrhost(var.dev_net_cidr, 1)}"

    static_ip_pool {
        start_address = "${cidrhost(var.dev_net_cidr, 10)}"
        end_address = "${cidrhost(var.dev_net_cidr, 200)}"
    }
}


# Jenkins VM on Development Network
resource "vcd_vapp" "jenkins" {
    name          = "jenkins01"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 2048
    cpus          = 2
    network_name  = "${vcd_network.dev_net.name}"
    ip            = "${var.jenkins_int_ip}"

    depends_on    = [ "vcd_dnat.jenkins-ssh", "vcd_firewall_rules.jenkins-fw", "vcd_snat.jenkins-outbound" ]

    connection {
        host = "${var.jenkins_ext_ip}"
        user = "${var.ssh_user}"
        password = "${var.ssh_password}"
    }

    provisioner "chef"  {
        run_list = ["chef-client","chef-client::config","chef-client::delete_validation","jenkins-server"]
        node_name = "${vcd_vapp.jenkins.name}"
        server_url = "https://api.chef.io/organizations/${var.chef_organisation}"
        validation_client_name = "${var.chef_organisation}-validator"
        validation_key = "${file("~/.chef/skyscapecloud-validator.pem")}"
        version = "${var.chef_client_version}"
        attributes {
            "jenkins-server" {
                "github" {
                    "oauth_user" = "${var.github_oauth_userid}"
                    "oauth_secret" = "${var.github_oauth_secret}"
                }
            }
        }
    }
}


# Inbound SSH to the Jenkins server
resource "vcd_dnat" "jenkins-ssh" {
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.jenkins_ext_ip}"
    port          = 22
    internal_ip   = "${var.jenkins_int_ip}"
}

# Inbound HTTP to the loadbalancer server
resource "vcd_dnat" "jenkins-http" {
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.jenkins_ext_ip}"
    port          = 8080
    internal_ip   = "${var.jenkins_int_ip}"
}

# SNAT Outbound traffic
resource "vcd_snat" "jenkins-outbound" {
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.jenkins_ext_ip}"
    internal_ip   = "${var.dev_net_cidr}"
}

resource "vcd_firewall_rules" "jenkins-fw" {
    edge_gateway   = "${var.edge_gateway}"
    default_action = "drop"

    depends_on     = [ "vcd_network.dev_net" ]

    rule {
        description      = "allow-jenkins-ssh"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "22"
        destination_ip   = "${var.jenkins_ext_ip}"
        source_port      = "any"
        source_ip        = "any"
    }

    rule {
        description      = "allow-jenkins-http"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "8080"
        destination_ip   = "${var.jenkins_ext_ip}"
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
        source_ip        = "${var.dev_net_cidr}"
    }
}
