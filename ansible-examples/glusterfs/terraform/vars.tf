variable "environment" {
  default = "dev"
}

# uncommend if using clouds.yaml
variable "cloud_name" {
   default = "demo-frn"
}

variable "ubuntu" {
    default = {
        demo-frn = "Ubuntu-18.04-LTS",
        demo-cor = "Ubuntu-18.04-LTS"
    }
}

variable "centos" {
    default = {
        demo-frn = "Centos 7 - LTS",
        demo-cor = "centos72"
    }
}

variable "flavor" {
  default = {
      small = "m1.small",
      medium = "m1.medium",
      large = "m1.large"
  }
}

variable "dns_nameservers" {
  default = [
      "8.8.4.4",
      "8.8.8.8"
  ]
}
variable "compute_count" {
    default = 2
}

variable "gluster_count" {
  default = 6
}

variable "compute_ports_tcp" {
    default = [
        "80",
        "443",
        "8080",
        "8443"
    ]
}

variable "cidr" {
  default = {
      vpn = "192.168.1.0/24",
      storage = "192.168.2.0/24",
      compute = "192.168.3.0/24"
  }
}

variable "key_pair_name" {
  default = "ewilliams-1"
}
