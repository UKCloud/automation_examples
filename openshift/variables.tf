variable "OS_TENANT_NAME" {}
variable "OS_TENANT_ID" {}
variable "OS_USERNAME" {}
variable "OS_PASSWORD" {}

variable "OS_REGION" { default = "regionOne" }
variable "OS_AUTH_URL" { default = "https://cor00005.cni.ukcloud.com:13000/v2.0" }
variable "OS_INTERNET_ID" { default = "893a5b59-081a-4e3a-ac50-1e54e262c3fa" }
variable "OS_INTERNET_NAME" { default = "internet" }

variable "IMAGE_NAME" { default = "CentOS 7" }
# variable "IMAGE_ID"   { default =  "32af054b-ab6d-448f-a4fd-b6b0ed089cc7" }

variable "infra_type" { default = "t1.medium" }
variable "master_type" { default = "t1.medium" }
variable "node_type" { default = "r1.small" }
# variable "etcd_type" { defualt = "t1.tiny" }
variable "haproxy_type" { default = "t1.small" }
# variable "router_type" { default = "t1.tiny" }

variable "OpenShift_Subnet" { default = "10.0.0.0/24" }
variable "DMZ_Subnet" { default = "10.100.0.0/24" }

variable "openshift_masters" { default = "3" }
variable "openshift_nodes" { default = "2" }
# variable "openshift_etcd" { default = "3" }
variable "openshift_loadbalancer" { default = "2" }
# variable "openshift_routers" { default = "1" }

variable "cluster_hostname" { default = "openshift" }
variable "domain_name" { default = "example.com" }
variable "app_subdomain" { default = "apps" }
variable "apps_domain_name" { default = "apps.example.com" }
variable "public_key_file" { default = "~/.ssh/user.pub" }
variable "private_key_file" { default = "~/.ssh/user.private" }

variable "mysql_powerdns_password" { default = "VerySecret" }
variable "powerdns_api_key" { default = "YouWontGuessThis" }
variable "ansible_hosts_file" { default = "files/ansible_hosts.tpl" }

variable "router_name" { default = "InternetGW" }

variable "availability_zones" { default = ["0000c-1", "0000c-2"] }

variable "master_node_labels" { default = "" }
variable "worker_node_labels" { default = "" }
variable "openshift_version" { default = "release-1.4" }

# variable "godaddy_key" {}
# variable "godaddy_secret" {}