# Terraform vCloud Director Provider v2 for

This directory contains a simple Terraform template for vCloud Director.

## Resources

It produces an environment with the following resources:

- 2 Networks
  - External
  - Internal
- 5 vApps
  - App
  - Bastion
  - OpenVPN
  - Db
  - Web
- NAT services
  - Source NAT for outgoing traffic
  - Destination NAT for incoming traffic (Web, OpenVPN, and Bastion SSH)
- Firewall Rules
  - SSH and OpenVPN incoming traffic
  - SSH traffic internal to and from the Bastion
  - Incoming Web traffic
- Outputs:
  - public_ip: public-facing IP address of edge gateway

## Usage

In the current directory, update the variables in `main.tf` with your vCloud Director credentials.

```bash
terraform init
terraform plan
terraform apply
```
