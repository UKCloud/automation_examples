##
## Skyscape PowerCLI example script
## Date written: Jan 2016 by Skyscape Cloud Services
##
## This script will shutdown and remove a named vApp from a specified Catalogue
## Connect to VCD API 
##
Connect-CIServer -server api.vcd.portal.skyscapecloud.com -Org 'ORGNAME' -Username 'USERNAME' -Password 'PASSWORD'
##
## Set the Live vAPP to be removed
##
##myOrgVDC = Read-Host ' Enter VDC vApp resides in'
$myVApp = Read-Host 'Enter vApp name to be removed'
$myCatalog = Read-Host 'Enter the name of Catalog vApp resides'
##remove $myVApp from specfied catalogue
Stop-CIVApp $myVApp
Get-CIVAppTemplate -name $myVApp -Catalog $myCatalog  | Remove-CIVAppTemplate
Get-CIVApp -Name $MyVApp | Remove-CIVApp
##
##
##
