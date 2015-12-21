# Automation Examples - Packer Templates

This directory contains a number of configuration files and scripts required to use the Packer tool from https://packer.io/ to create and upload to vCloud Director, a new vApp Template which is subsequently used in the automation examples in this repository.

To build and deploy a CentOS 7.1 vApp Template, you will first need to download and install the following tools:
* Packer - download from https://packer.io/downloads.html
* ovftools - download from https://www.vmware.com/support/developer/ovf/
* VMware Workstation - Evaluation license can be used for 30 days

Having installed the above pre-requisits, the first step is to git clone this directory and run:
```
packer build centos71.json
```
What this will do is download the CentOS7.1 installation ISO, create a new VM in VMware Workstation and perform an automated installation using the kickstart script in the http directory. Once the installation completes, packer will make an SSH connection to the new VM and run further customisation scripts to install amongst other things, the open-vm-tools package required for VM customisation.

The output from Packer will be a set of files in the `output-cnetos71-vmware-iso` directory. Before these files can be uploaded to vCloud Director, we need to make a single edit to the `centos71.vmx` file. Open the file in a text editor like Notepad and locate the line:
```
ethernet0.connectiontype = "nat"
```
Replace "nat" with "none" and save the file. Without this change, when vCloud Director clones the VM to create a new vApp, it will fail because "nat" is not a known network name.

To upload the new VM template to vCloud Director, you now use the ovftool command. Assuming that you have already created a Catalog in your vCloud Organisation (mine is called DevOps) run the following from the `output-centos71-vmware-iso` directory:
```
ovftool --vCloudTemplate --acceptAllEulas --overwrite centos71.vmx "vcloud://%VCAIR_USERNAME%@api.vcd.portal.skyscapecloud.com:443?org=%VCAIR_ORG%&vappTemplate=centos71&catalog=DevOps"
```
Your vCloud username and organisation are read from the corresponding `VCAIR_USERNAME` and `VCAIR_ORG` environment variables and you will be prompted for your password. Update the url as appropriate to match your catalog name and the name of the vApp Template you are uploading.