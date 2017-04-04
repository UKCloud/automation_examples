# provider "godaddy" {
#     key = "${var.godaddy_key}"
#     secret = "${var.godaddy_secret}"
# }

# resource "godaddy_domain_record" "openshift" {
#   domain   = "devops-consultant.net"
# #   customer = "1234"                         // required if provider key does not belong to customer

#   record {
#     name = "openshift"
#     type = "A"
#     data = "${openstack_compute_floatingip_v2.loadbalancer_ip.address}"
#     ttl = 3600
#   }

# #   addresses   = ["192.168.1.2", "192.168.1.3"]
#   nameservers = ["ns27.domaincontrol.com", "ns28.domaincontrol.com"]
# }

# resource "godaddy_zone_record" "openshift" {
#   domain = "devops-consultant.net"
#   #customer = "1234"

#   name = "openshift"
#   type = "A"
#   data = "${openstack_compute_floatingip_v2.loadbalancer_ip.address}"
#   ttl = 3600
# }