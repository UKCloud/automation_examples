# Jumpbox VM on the Management Network
resource "vcd_vapp" "jumpbox" {
    name          = "demojumpbox01"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 512
    cpus          = 1
    network_name  = "${vcd_network.mgt_net.name}"
    ip            = "${var.jumpbox_int_ip}"
}


# Database VM on the Database network
resource "vcd_vapp" "database" {
    name          = "demodb01"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 2048
    cpus          = 2
    network_name  = "${vcd_network.data_net.name}"
    ip            = "${var.database_int_ip}"
}

# Load-balancer VM on the Webserver network
resource "vcd_vapp" "haproxy" {
    name          = "demolb01"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 1024
    cpus          = 1

    network_name  = "${vcd_network.web_net.name}"
    ip            = "${var.haproxy_int_ip}"
}

# Webserver VMs on the Webserver network
resource "vcd_vapp" "webservers" {
    name          = "${format("demoweb%02d", count.index + 1)}"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = 1024
    cpus          = 1
    network_name  = "${vcd_network.web_net.name}"
    ip            = "${cidrhost(var.web_net_cidr, count.index + 100)}"

    count         = "${var.webserver_count}"
}

# Define all the Chef Provisioning
resource "null_resource" "jumpbox" {
    depends_on = [ "vcd_vapp.jumpbox", "vcd_dnat.jumpbox-ssh", "vcd_firewall_rules.website-fw", "vcd_snat.website-outbound" ]

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


resource "null_resource" "database" {
    depends_on = [ "vcd_vapp.jumpbox", "vcd_dnat.jumpbox-ssh", "vcd_firewall_rules.website-fw", "vcd_snat.website-outbound" ]

    connection {
        bastion_host = "${var.jumpbox_ext_ip}"
        bastion_user = "${var.ssh_user}"
        bastion_password = "${var.ssh_password}"

        host = "${vcd_vapp.database.ip}"
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

resource "null_resource" "webservers" {
    depends_on = [ "vcd_vapp.jumpbox", "vcd_dnat.jumpbox-ssh", "vcd_firewall_rules.website-fw", "vcd_snat.website-outbound", "null_resource.database", "vcd_vapp.webservers" ]

    count         = "${var.webserver_count}"

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
        node_name = "${format("demoweb%02d", count.index + 1)}"
        server_url = "https://api.chef.io/organizations/${var.chef_organisation}"
        validation_client_name = "${var.chef_organisation}-validator"
        validation_key = "${file("~/.chef/${var.chef_organisation}-validator.pem")}"
        version = "${var.chef_client_version}"
        attributes {
            "tags" = [ "webserver" ]
        }
    }            
}

resource "null_resource" "haproxy" {
    depends_on = [ "vcd_vapp.jumpbox", "vcd_dnat.jumpbox-ssh", "vcd_firewall_rules.website-fw", "vcd_snat.website-outbound", "null_resource.webservers" ]

    connection {
        bastion_host = "${var.jumpbox_ext_ip}"
        bastion_user = "${var.ssh_user}"
        bastion_password = "${var.ssh_password}"

        host = "${vcd_vapp.haproxy.ip}"
        user = "${var.ssh_user}"
        password = "${var.ssh_password}"
    }

    provisioner "chef"  {
        run_list = [ "chef-client", "chef-client::config", "chef-client::delete_validation", "my_web_app::load_balancer" ]
        node_name = "${vcd_vapp.haproxy.name}"
        server_url = "https://api.chef.io/organizations/${var.chef_organisation}"
        validation_client_name = "${var.chef_organisation}-validator"
        validation_key = "${file("~/.chef/${var.chef_organisation}-validator.pem")}"
        version = "${var.chef_client_version}"
    }        
}

