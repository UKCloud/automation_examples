cd output-centos71-vmware-iso
sed -i.bak s/"nat"/"none"/ centos71.vmx
ovftool --vCloudTemplate --acceptAllEulas --overwrite centos71.vmx "vcloud://%VCAIR_USERNAME%@api.vcd.portal.skyscapecloud.com:443?org=%VCAIR_ORG%&vappTemplate=centos71&catalog=DevOps"