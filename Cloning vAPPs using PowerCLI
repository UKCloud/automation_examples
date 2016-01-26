##
## Skyscape PowerCLI example script
## Date written: Jan 2016 by Skyscape Cloud Services
##
## This script will capture a named vApp and clone into a designated Catalogue
## Option to deploy script after if required
## 
##
## Connect to VCD API 
##
Connect-CIServer -server api.vcd.portal.skyscapecloud.com -Org 'ORGNAME' -Username 'USERNAME' -Password 'PASSWORD'
##
## Set the Live vAPP to be captured 
##
## $myOrgVDC = Read-Host ' Enter VDC vApp resides in'
$myVApp = Read-Host 'Enter vApp name to be cloned'
$newVapp = Read-Host 'Enter new vApp name'
$myCatalog = Read-Host 'Enter the name of Catalog to be used'
$deploy = Read-Host 'Do want to deploy after capture? yes/no'
##
##
## Clone vApp into Catalogue using new name
##
New-CIVAppTemplate -Name $newVapp -VApp $myVApp -OrgVdc $myOrgVDC -Catalog $myCatalog
##
##Deploy new vApp from clone 
if ($deploy = 'yes') {
New-CIVApp -Name $newVapp -VAppTemplate $newVapp
Start-CIVApp -VApp $newVapp -Confirm:$false}
else {end}
##
##
