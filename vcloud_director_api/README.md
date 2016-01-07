## vCloud Director API ##

This directory contains sample scripts making use of the vCloud Director API directly.

To run the ruby scripts you will need to set the following environment variables containing your Skyscape Cloud user credentials:
```
VCAIR_ORG=1-2-33-456789
VCAIR_USERNAME=1234.5.67890
VCAIR_PASSWORD=Secret
```
The scripts were developed and tested using the [Chef Development Kit](https://downloads.chef.io/chef-dk/) and were executed by running:
```
chef exec ruby storage_profile.rb
```