variable "OS_TENANT_NAME" {}
variable "OS_TENANT_ID" {}
variable "OS_USERNAME" {}
variable "OS_PASSWORD" {}
variable "OS_REGION" { default = "regionOne" }
variable "OS_AUTH_URL" { 
	type = "map"
	default = {
		production = "https://cor00005.cni.ukcloud.com:13000/v2.0"
		beta = "https://beta.openstack.skyscapecloud.com:13000/v2.0"
	}
}

variable "OS_INTERNET_ID" {
	type = "map"
	default = {
		production = "893a5b59-081a-4e3a-ac50-1e54e262c3fa"
		beta = "1fa82a9d-d87d-4b43-b6dd-54bcbef184d3" 
	}
}

variable "OS_INTERNET_NAME" {
	type = "map"
	default = {
		production = "internet"
		beta = "Internet" 
	}
}

variable "PLATFORM" { default = "beta" }

variable "IMAGE_NAME" { default = "CentOS 7" }
variable "IMAGE_ID"   { default =  "32af054b-ab6d-448f-a4fd-b6b0ed089cc7" }
variable "infra_type" { default = "t1.tiny" }
variable "master_type" { default = "t1.tiny" }
variable "node_type" { default = "t1.tiny" }
variable "etcd_type" { defualt = "t1.tiny" }
variable "haproxy_type" { default = "t1.tiny" }

variable "OpenShift_Subnet" { default = "10.0.0.0/24" }
variable "Management_Subnet" { default = "192.168.1.0/24" }

variable "openshift_masters" { default = "3" }
variable "openshift_nodes" { default = "3" }
variable "openshift_etcd" { default = "3" }

variable "domain_name" { default = "example.com" }
variable "apps_domain_name" { default = "apps.example.com" }
variable "public_key_file" { default = "~/.ssh/user.pub" }
variable "private_key_file" { default = "~/.ssh/user.private" }

variable "mysql_powerdns_password" { default = "VerySecret" }
variable "powerdns_api_key" { default = "YouWontGuessThis" }