variable "version" {
  default = "0.2"
}

variable "vcd_logging" {
  description = "Verbose logging to ./go-vcloud-director.log"
  default     = true
}

variable "catalog" {
  description = "Public Catalogue"
  default     = "Skyscape Catalogue"
}

variable "public_ip" {
  description = "Edge Gateway public IP address"
  default     = "gw_public_ip"
}

variable "vcd_max_retry_timeout" {
  description = "Timeout for API operations"
  default     = 1200
}

variable "centos" {
  description = "Name of CentOS template in catalog"
  default     = "Skyscape_CentOS_7_3_x64_60GB_Small_v1.0.2"
}

variable "ubuntu" {
  description = "Name of Ubuntu template in catalog"
  default     = "Standard Skyscape Ubuntu 16.04.1-(Patched-15-08-2016)-Template"
}

variable "vcd_creds" {
  description = "Map of credentials from vcloud director instance"

  default = {
    username = "0000.0.000aaa"
    password = "T036hp455"
    org      = "0-0-000-00a000"
    vdc      = "A-ESS-vdc-handle"
    url      = "https://api.vcd.00000f.r0000f.reg.portal.skyscapecloud.com/api"
  }
}

variable "vcd_allow_unverified_ssl" {
  default = true
}

variable "vcd_edgegateway" {
  default = "Internet_02(nti0001ci0_0-0-000)"
}

variable "cidr" {
  default = {
    external = "172.16.3.0/24"
    internal = "172.16.2.0/24"
  }
}

variable "external" {
  default = {
    gw                   = "172.16.3.1"
    static_start_address = "172.16.3.2"
    static_end_address   = "172.16.3.100"
    dhcp_start_address   = "172.16.3.101"
    dhcp_end_address     = "172.16.3.200"
  }
}

variable "internal" {
  default = {
    gw                   = "172.16.2.1"
    static_start_address = "172.16.2.2"
    static_end_address   = "172.16.2.100"
    dhcp_start_address   = "172.16.2.101"
    dhcp_end_address     = "172.16.2.200"
  }
}

resource "vcd_network_routed" "external" {
  org = "${var.vcd_creds["org"]}"
  vdc = "${var.vcd_creds["vdc"]}"

  name         = "external-network"
  edge_gateway = "${var.vcd_edgegateway}"
  gateway      = "${var.external["gw"]}"

  static_ip_pool = {
    start_address = "${var.external["static_start_address"]}"
    end_address   = "${var.external["static_end_address"]}"
  }

  dns1 = "8.8.8.8"
  dns2 = "8.8.4.4"

  dhcp_pool = {
    start_address = "${var.external["dhcp_start_address"]}"
    end_address   = "${var.external["dhcp_end_address"]}"
  }
}

resource "vcd_network_routed" "internal" {
  org = "${var.vcd_creds["org"]}"
  vdc = "${var.vcd_creds["vdc"]}"

  name         = "internal-network"
  edge_gateway = "${var.vcd_edgegateway}"
  gateway      = "${var.internal["gw"]}"

  dhcp_pool = {
    start_address = "${var.internal["dhcp_start_address"]}"
    end_address   = "${var.internal["dhcp_end_address"]}"
  }

  static_ip_pool = {
    start_address = "${var.internal["static_start_address"]}"
    end_address   = "${var.internal["static_end_address"]}"
  }
}

resource "vcd_vapp" "openvpn" {
  name       = "OpenVPN"
  depends_on = ["vcd_network_routed.external"]
}

resource "vcd_vapp" "web" {
  name       = "Web"
  depends_on = ["vcd_network_routed.external"]
}

resource "vcd_vapp" "app" {
  name       = "App"
  depends_on = ["vcd_network_routed.internal"]
}

resource "vcd_vapp" "db" {
  name       = "Db"
  depends_on = ["vcd_network_routed.internal"]
}

resource "vcd_vapp" "bastion" {
  name       = "Bastion"
  depends_on = ["vcd_network_routed.external"]
}

resource "vcd_vapp_vm" "bastion" {
  name          = "bastion"
  vapp_name     = "${vcd_vapp.bastion.name}"
  catalog_name  = "${var.catalog}"
  template_name = "${var.centos}"
  memory        = 2048
  cpus          = 2
  network_name  = "${vcd_network_routed.external.name}"
  ip            = "allocated"
  depends_on    = ["vcd_vapp.bastion"]
}

resource "vcd_vapp_vm" "openvpn-server" {
  name          = "openvpn-server"
  vapp_name     = "${vcd_vapp.openvpn.name}"
  catalog_name  = "${var.catalog}"
  template_name = "${var.centos}"
  cpus          = 2
  network_name  = "${vcd_network_routed.external.name}"
  ip            = "allocated"
  depends_on    = ["vcd_vapp.openvpn"]
}

resource "vcd_vapp_vm" "app" {
  count         = 1
  name          = "app-${format("%02d", count.index+1)}"
  vapp_name     = "${vcd_vapp.app.name}"
  catalog_name  = "${var.catalog}"
  template_name = "${var.centos}"
  memory        = 2048
  cpus          = 2
  network_name  = "${vcd_network_routed.internal.name}"
  ip            = "allocated"
  depends_on    = ["vcd_vapp.app"]
}

resource "vcd_vapp_vm" "web" {
  count         = 2
  name          = "web-${format("%02d", count.index+1)}"
  vapp_name     = "${vcd_vapp.web.name}"
  catalog_name  = "${var.catalog}"
  template_name = "${var.centos}"
  memory        = 2048
  cpus          = 2
  network_name  = "${vcd_network_routed.external.name}"
  ip            = "allocated"
  depends_on    = ["vcd_vapp.web"]
}

resource "vcd_vapp_vm" "db" {
  count         = 1
  name          = "db-${format("%02d", count.index+1)}"
  vapp_name     = "${vcd_vapp.db.name}"
  catalog_name  = "${var.catalog}"
  template_name = "${var.centos}"
  memory        = 2048
  cpus          = 2
  network_name  = "${vcd_network_routed.internal.name}"
  ip            = "allocated"
  depends_on    = ["vcd_vapp.db"]
}

resource "vcd_dnat" "ssh" {
  org             = "${var.vcd_creds["org"]}"
  vdc             = "${var.vcd_creds["vdc"]}"
  edge_gateway    = "${var.vcd_edgegateway}"
  external_ip     = "${var.public_ip}"
  port            = 22022
  internal_ip     = "${vcd_vapp_vm.bastion.ip}"
  translated_port = 22
}

resource "vcd_dnat" "openvpn" {
  org             = "${var.vcd_creds["org"]}"
  vdc             = "${var.vcd_creds["vdc"]}"
  edge_gateway    = "${var.vcd_edgegateway}"
  external_ip     = "${var.public_ip}"
  port            = 3128
  internal_ip     = "${vcd_vapp_vm.openvpn-server.ip}"
  translated_port = 3128
}

resource "vcd_firewall_rules" "fw" {
  edge_gateway   = "${var.vcd_edgegateway}"
  default_action = "drop"

  rule {
    description      = "allow app"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "8080"
    destination_ip   = "${var.cidr["internal"]}"
    source_port      = "any"
    source_ip        = "${var.cidr["external"]}"
  }

  rule {
    description      = "allow db"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "3306"
    destination_ip   = "${var.cidr["internal"]}"
    source_port      = "any"
    source_ip        = "${var.cidr["internal"]}"
  }

  rule {
    description      = "allow-outbound"
    policy           = "allow"
    protocol         = "any"
    destination_port = "any"
    destination_ip   = "any"
    source_port      = "any"
    source_ip        = "${var.cidr["external"]}"
  }

  rule {
    description      = "allow-ssh"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "22022"
    destination_ip   = "${var.public_ip}"
    source_port      = "any"
    source_ip        = "any"
  }

  rule {
    description      = "allow-openvpn"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "3128"
    destination_ip   = "${var.public_ip}"
    source_port      = "any"
    source_ip        = "any"
  }

  rule {
    description      = "allow SSH bastion -> intern"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "22"
    source_port      = "any"
    source_ip        = "${vcd_vapp_vm.bastion.ip}"
    destination_ip   = "${var.cidr["internal"]}"
  }

  rule {
    description      = "allow SSH bastion -> extern"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "22"
    source_port      = "any"
    source_ip        = "${vcd_vapp_vm.bastion.ip}"
    destination_ip   = "${var.cidr["external"]}"
  }

  depends_on = ["vcd_snat.outbound-external", "vcd_snat.internal"]
}

resource "vcd_snat" "outbound-external" {
  edge_gateway = "${var.vcd_edgegateway}"
  external_ip  = "${var.public_ip}"
  internal_ip  = "${var.cidr["external"]}"
}

resource "vcd_snat" "internal" {
  edge_gateway = "${var.vcd_edgegateway}"
  external_ip  = "${var.public_ip}"
  internal_ip  = "${var.cidr["internal"]}"
}

output "bastion_ip" {
  value = "${vcd_vapp_vm.bastion.ip}"
}

output "openvpn_ip" {
  value = "${vcd_vapp.openvpn-server.ip}"
}
