# Inbound SSH to the Jumpbox server
resource "vcd_dnat" "jumpbox-ssh" {
    depends_on    = [ "vcd_network.mgt_net" ]
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.jumpbox_ext_ip}"
    port          = 22
    internal_ip   = "${var.jumpbox_int_ip}"
}

# Inbound HTTP to the loadbalancer server
resource "vcd_dnat" "loadbalance-http" {
    depends_on    = [ "vcd_network.web_net" ]
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.website_ip}"
    port          = 80
    internal_ip   = "${var.haproxy_int_ip}"
}

resource "vcd_dnat" "loadbalancer-stats" {
    depends_on    = [ "vcd_network.web_net" ]
    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.website_ip}"
    port          = 8080
    internal_ip   = "${var.haproxy_int_ip}"
}

# SNAT Outbound traffic
resource "vcd_snat" "website-outbound" {
    depends_on    = [ "vcd_network.mgt_net", "vcd_network.data_net", "vcd_network.web_net" ]
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
