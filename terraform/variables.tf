variable "vcd_org" {}
variable "vcd_userid" {}
variable "vcd_pass" {}
variable "vcd_url" { default = "https://api.vcd.portal.skyscapecloud.com/api" }
variable "catalog" { default = "DevOps" }
variable "vapp_template" { default = "centos71" }
variable "edge_gateway" { default = "Edge Gateway Name" }
variable "jumpbox_ext_ip" { default = "51.179.193.253" }
variable "website_ip" { default = "51.179.193.253" }

variable "chef_client_version" { default = "12.6.0" }
variable "chef_organisation" { default = "skyscapecloud" }
variable "chef_userid" { default = "rcoward" }

variable "ssh_user" { default = "vagrant" }
variable "ssh_password" { default = "vagrant" }

variable "mgt_net_cidr" { default = "10.150.1.0/24" }
variable "web_net_cidr" { default = "10.150.2.0/24" }
variable "data_net_cidr" { default = "10.150.3.0/24" }

variable "jumpbox_int_ip" { default = "10.150.1.100" }
variable "database_int_ip" { default = "10.150.3.100" }
variable "haproxy_int_ip" { default = "10.150.2.10" }

variable "webserver_count" { default = 2 }
