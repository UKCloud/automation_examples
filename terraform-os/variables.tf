variable "OS_TENANT_NAME" {}
variable "OS_USERNAME" {}
variable "OS_PASSWORD" {}
variable "OS_AUTH_URL" { default = "https://beta.openstack.skyscapecloud.com:13000/v2.0" }

variable "OS_INTERNET_GATEWAY_ID" { default = "1fa82a9d-d87d-4b43-b6dd-54bcbef184d3" }

variable "IMAGE_NAME" { default = "Centos7" }
variable "IMAGE_ID"   { default =  "4be3ff7d-5e54-4ad4-ba23-af392cdca546" }
variable "INSTANCE_TYPE" { default = "t1.tiny" }

variable "SSH_KEY"    { default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEArrSmhh3oGC/zCorMpOXXppYCRLQMzUpdyQotCuXQ8uD4JHitbReQBT0LuaCtei4xxLcdnpNW7DM/xLfl0yZLWRk0iH5VFjPxvYsgVzhysO8nvG6l2p3RDJOrA2mQROl5yDaAWUE/J2vKezzNJf9f8/JZyuWWafPa89+XTPR3VAuQCzRrCmskW1rpok29IpqM/jM7QCfG20Y7/lLOaCW9UlEAO++WTDQS4X6t6Xf5Lsg6TMGrMuPSQzjUTMGvfhT3dnTuhALLW5bYQirkgAWwSPoHx5yeZZnhH1C0T2ak0Dhx0tlm9sr82DU6x0INWENcdMj95oFlceA5DOqQ/3s3jw==" }

variable "DMZ_Subnet" { default = "192.168.199.0/24" }