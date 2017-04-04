# Configure the OpenStack Provider
provider "openstack" {
    user_name   = "${var.OS_USERNAME}"
    tenant_name = "${var.OS_TENANT_NAME}"
    password    = "${var.OS_PASSWORD}"
    auth_url    = "${var.OS_AUTH_URL}"
    insecure    = "false"
}

resource "openstack_compute_keypair_v2" "ssh-keypair" {
  name       = "terraform-keypair"
  public_key = "${file(var.public_key_file)}"
}



