# Configure the VMware vCloud Director Provider
provider "vcd" {
    user            = "${var.vcd_userid}"
    org             = "${var.vcd_org}"
    url				= "${var.vcd_url}"
    password        = "${var.vcd_pass}"
    maxRetryTimeout = 300
}

# Create our networks
resource "vcd_network" "mgt_net" {
    name = "N-Tier Demo Mgt Network"
    edge_gateway = "${var.edge_gateway}"
    gateway = "${cidrhost(var.mgt_net_cidr, 1)}"

    static_ip_pool {
        start_address = "${cidrhost(var.mgt_net_cidr, 10)}"
        end_address = "${cidrhost(var.mgt_net_cidr, 200)}"
    }
}

resource "vcd_network" "web_net" {
    name = "N-Tier Demo Webserver Network"
    edge_gateway = "${var.edge_gateway}"
    gateway = "${cidrhost(var.web_net_cidr, 1)}"

    static_ip_pool {
        start_address = "${cidrhost(var.web_net_cidr, 10)}"
        end_address = "${cidrhost(var.web_net_cidr, 200)}"
    }
}

resource "vcd_network" "data_net" {
    name = "N-Tier Demo Database Network"
    edge_gateway = "${var.edge_gateway}"
    gateway = "${cidrhost(var.data_net_cidr, 1)}"

    static_ip_pool {
        start_address = "${cidrhost(var.data_net_cidr, 10)}"
        end_address = "${cidrhost(var.data_net_cidr, 200)}"
    }
}

