variable "cloud_name" {
    default = "demo-cor"
    description = "Name of cloud's entry in clouds.yaml"
}

variable "keypair_name" {
    default = "ewilliams-1"
    description = "Keypair to use for this demo"
}

variable "num_nets" {
    default = 3
}

variable "allowed_ports" {
    default = [
        22,
        80,
        443,
        8443,
    ]
    description = "Ports open to traffic from the internet"
}

variable "flavors" {
    default = {
        small = "t1.tiny",
        medium = "t1.large",
        large = "m1.small"
    }
    description = ""
}

variable "centos" {
    default =  {
        demo-frn = "Centos 7 - LTS",
        demo-cor = "centos72"
    }
    description = "CentOS names for different clouds"
}

variable "ubuntu" {
    default =  {
        demo-frn = "Ubuntu 16.04 amd64",
        demo-cor = "Ubuntu 18.04 amd64"
    }
    description = "Ubuntu image names for different clouds"
}

variable "keypair_name" {
    default = "ewilliams-1"
    description = "Keypair to use for this demo"
}

variable "dns_servers" {
    default = [
        "8.8.8.8",
        "8.8.4.4"
    ]
    description = ""
}

variable "floating_ip_pool" {
    default = "internet"
    description = "Name of the floating IP pool"
}

variable "network_name" {
    default = "networks"
    description = "Name of network for these dudes"
}

variable "cidr_template" {
    default = "172.16.%d.0/24"
}

variable "router_name" {
    default = "router_1"
    description = ""
}
