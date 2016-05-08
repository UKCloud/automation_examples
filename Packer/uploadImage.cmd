cd output-centos71-vmware-iso
sed -i.bak s/"nat"/"none"/ centos71.vmx
ovftool --vCloudTemplate --acceptAllEulas --overwrite centos72.vmx "vcloud://%VCLOUD_USERNAME%@api.vcd.portal.skyscapecloud.com:443?org=%VCLOUD_ORG%&vappTemplate=centos72&catalog=DevOps"