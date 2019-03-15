# Azure Deployment Example

This Azure Resource Manager (ARM) template will deploy a simple 2-tiered
infrastructure with load-balancer.  This is suitable for hosting a scaleable,
highly-available web application with database backend.

## Resources Created:

- Azure Storage Account
- Virtual Network
- Security groups
- Load Balancer
- Public IP Address
- 1 Bastion Host
- 2 Availability Sets
- 2 frontend VMs
- 2 database VMs

## Pre-requisites

- [az][az] Azure command line interface
- Python and [PyYAML][pyyaml] for compiling YAML to JSON (optional)

## Usage

Create a resource group named `rg-dev-webapp` to hold the resources created. To
use another name, update the parameters file, `site.parameters.json`.

`az group create --name rg-dev-webapp --location frn00006`

Hint: Use `az account list-locations` to see available locations for your
account.

Deploy the template using the CLI:

```bash
az group deployment create  --template-file site.json \
                            --parameters site.parameters.json \
                            --name webapp \
                            --resource-group rg-dev-webapp
```

## Teardown

To easily remove the stack, delete the resource group:

```bash
az group delete --name rg-dev-webapp
```

[az]:https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
[pyyaml]:https://pypi.org/project/PyYAML/
