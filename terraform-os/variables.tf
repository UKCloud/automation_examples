variable "OS_TENANT_NAME" {}
variable "OS_USERNAME" {}
variable "OS_PASSWORD" {}
variable "OS_AUTH_URL" { default = "https://beta.openstack.skyscapecloud.com:13000/v2.0" }

variable "OS_INTERNET_GATEWAY_ID" { default = "1fa82a9d-d87d-4b43-b6dd-54bcbef184d3" }

variable "IMAGE_NAME" { default = "Centos7" }
variable "IMAGE_ID"   { default =  "4be3ff7d-5e54-4ad4-ba23-af392cdca546" }
variable "INSTANCE_TYPE" { default = "t1.tiny" }