# Using Terraform and Chef to deploy a Web App
This is the accompanying code and configuration files used by the blog post "[vCloud Director and Terraform](http://robcoward.blogspot.com/2016/03/vcloud-director-and-terraform.html)".

To use this sample configuration to build your own N-Tier web app deployment you need to download and install:
* [ChefDK](https://downloads.chef.io/chef-dk/)
* [Terraform](https://www.terraform.io/downloads.html)
* [Graphviz](http://www.graphviz.org/Download.php) (optional)


It also assumes that you have a suitable vApp Template you can use to create a new VM and boot into the OS with credentials that Terraform can use to connect over SSH and run commands. You could follow the following "[vApp Templates for Automation](http://robcoward.blogspot.com/2015/12/creating-vapp-templates-for-automation.html)" blog post to create your vApp Template.

If you do not have access to a Chef Server, you will need to [sign up for Chef's Hosted Service](https://manage.chef.io/signup) - free for up to 5 servers , which is all you will need for this demo.

----------

Setting up your Chef Server
=======

This repository contains a Berksfile configuration file than can help us to ensure your chef server has all the required cookbooks uploaded, with their dependencies, so that we can get Terraform to automatically register new VMs with the Chef Server.

Having installed the Chef Development Kit, open a command prompt and change directory to where you have checked-out this repository. Then you will need to run:
``` bash
berks install
berks upload
```
It will retrieve the my_web_app cookbook from this same repository and recursively retrieve from the [Chef Supermarket](https://supermarket.chef.io/) site, all recursive cookbook dependencies needed to deploy the application. Berkshelf caches all the cookbooks locally with the install command, and then uploads them to the Chef Server, relying on you having a working knife configuration file ( you can download one from https://manage.chef.io/ )


----------


Once your Chef Server is prepared, you will want to run the following command, substituting your vCloud API details that you can retrieve from the [Skyscape Portal API](https://portal.skyscapecloud.com/user/api) page:
``` bash
terraform plan --var vcd_org=1-111-1-111111 --var vcd_userid=2222.222.222222 --var vcd_pass=SuperSecret --var catalog=MyCatalog --var vapp_template=MyTemplate --var jumpbox_ext_ip=1.2.3.4 --var website_ip=1.2.3.5 --var chef_organisation=MyChefOrg
```
If all is well, the output will list all the resources that Terraform will create if you subsequently run it with the apply command.

To generate a resource dependency tree, showing all the resources defined in the Terraform configuration and the implicit and explicit dependencies between them that will affect the order Terraform creates the resources, run:
``` bash
terraform graph > resources.dot
dot -Tpng -o resources.png resources.dot
```
