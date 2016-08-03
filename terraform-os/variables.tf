variable "OS_TENANT_NAME" {}
variable "OS_USERNAME" {}
variable "OS_PASSWORD" {}
variable "OS_AUTH_URL" { default = "https://cor00005.cni.ukcloud.com:13000/v2.0" }

variable "OS_INTERNET_GATEWAY_ID" { default = "a8858b68-877a-4130-9590-2f8d5bbf59d7" }

variable "IMAGE_NAME" { default = "CentOS 7" }
variable "IMAGE_ID"   { default =  "32af054b-ab6d-448f-a4fd-b6b0ed089cc7" }
variable "INSTANCE_TYPE" { default = "t1.tiny" }

variable "SSH_KEY"    { default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEArrSmhh3oGC/zCorMpOXXppYCRLQMzUpdyQotCuXQ8uD4JHitbReQBT0LuaCtei4xxLcdnpNW7DM/xLfl0yZLWRk0iH5VFjPxvYsgVzhysO8nvG6l2p3RDJOrA2mQROl5yDaAWUE/J2vKezzNJf9f8/JZyuWWafPa89+XTPR3VAuQCzRrCmskW1rpok29IpqM/jM7QCfG20Y7/lLOaCW9UlEAO++WTDQS4X6t6Xf5Lsg6TMGrMuPSQzjUTMGvfhT3dnTuhALLW5bYQirkgAWwSPoHx5yeZZnhH1C0T2ak0Dhx0tlm9sr82DU6x0INWENcdMj95oFlceA5DOqQ/3s3jw==" }

variable "DMZ_Subnet" { default = "192.168.199.0/24" }