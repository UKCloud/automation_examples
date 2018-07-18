## Volume Snapshot Management demo

This is a demonstration of using [UKCloud Cloud Storage][cloudstorage] to make encrypted backups of servers in [UKCloud for OpenStack][openstack].

## Running the Demo

The demo is run by executing the script "create_demo.sh" in the project directory:

```bash

./create_demo.sh

```

If you wish to run the demo without using Docker, add the argument `nodocker` to the end of the command:

```bash

./create_demo.sh nodocker

```

This will perform the following tasks:

* Create a server in the OpenStack environment
* Create a snapshot of the server's volume
* Send a compressed and encrypted backup of the volume to S3 storage in the bucket `snapshots/${servername}`
* Delete the snapshot

## Prerequisites

1. UKCloud Cloud Storage Account
2. UKCloud OpenStack Credentials
3. Docker (alternatively, install Ansible and Terraform on your local machine)

## Getting Started

You'll need the following to use this demo:

1. Your Cloud Storage Credentials
2. Your OpenStack Credentials for the Corsham region. You can get these in the [OpenStack Dashboard][horizon]
3. (Optional) [Install Docker][docker]
### OpenStack Credentials

Copy the file `clouds.yaml.sample` to `clouds.yaml` and fill in the correct values for `demo-cor`

```yaml

clouds:
  demo-cor:
    auth:
      auth_url: https://cor00005.cni.ukcloud.com:13000/v2.0
      tenant_name: "Contents of OS_TENANT"
      project_name: "Contents of OS_TENANT"
      username: user@example.com
      password: "password_goes_here"
  demo-frn:
    auth:
      auth_url: https://frn00006.cni.ukcloud.com:13000/v2.0
      tenant_name: "Contents of OS_TENANT"
      project_name: "Contents of OS_TENANT"
      username: user@example.com
      password: "password_goes_here"
ansible:
  use_hostnames: true
```

Next, copy the file `$PROJECT_DIR/vars/s3.yaml.sample` to `$PROJECT_DIR/vars/s3.yaml` and update with your proper credentials.

```yaml

```

You can get these credentials from the [UKCloud Portal][portal].

```yaml

aws_access_key_id: 1-b-c-123-12345-f
aws_secret_access_key: iasdfasdf0(FD(S*FDSF/sdfsdfsdf))
aws_endpoint_host: cas.frn00006.ukcloud.com
gpg_passphrase: correct horse battery staple

```

Additionally, you may want to set your own password for the GPG-based encryption used on the backup files.  This value is set in the variable `gpg_passphrase`

[horizon]:https://cor00005.cni.ukcloud.com/
[portal]:https://portal.skyscapecloud.com/login
[cloudstorage]:https://ukcloud.com/what-we-do/infrastructure-as-a-service/storage/cloud-storage
[openstack]:https://ukcloud.com/openstack
[docker]:https://store.docker.com/search?type=edition&offering=community
