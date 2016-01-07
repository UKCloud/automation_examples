## Using CURL from the Command Line ##

These are some example curl commands you can use to interact with vCloud Director. These examples assume that your user credentials are stored in environment variables, so you will need to setup the following variables in order to copy / paste the commands:
```
VCAIR_ORG=1-2-33-456789
VCAIR_USERNAME=1234.5.67890
VCAIR_PASSWORD=Secret
```

Logging In
-------
This command authenticates your user credentials with vCloud Director and returns the authentication token you will need to include in subsequent API calls.
```
> curl -u %VCAIR_USERNAME%@%VCAIR_ORG%:%VCAIR_PASSWORD%  -H "Accept: application/*+xml;version=5.6" -X POST -i https://api.vcd.portal.skyscapecloud.com/api/sessions
HTTP/1.1 200 OK
Date: Wed, 06 Jan 2016 11:19:10 GMT
X-VMWARE-VCLOUD-REQUEST-ID: abcdefgh-1234-5678-9012-abcdefghijkl
x-vcloud-authorization: a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6
Set-Cookie: vcloud-token=a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6; Secure; Path=/
Content-Type: application/vnd.vmware.vcloud.session+xml;version=5.6
Date: Wed, 06 Jan 2016 11:19:11 GMT
X-VMWARE-VCLOUD-REQUEST-EXECUTION-TIME: 836
Connection: close

<?xml version="1.0" encoding="UTF-8"?>
<Session xmlns="http://www.vmware.com/vcloud/v1.5" org="1-2-33-456789" user="1234.5.67890" userId="urn:vcloud:user:1a2b3c4d-e5f6-7a8b-9c0d-e1f2a3b4c5d6" href="https://api.vcd.portal.skyscapecloud.com/api/session" type="application/vnd.vmware.vcloud.session+xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/vcloud/v1.5 http://10.10.6.11/api/v1.5/schema/master.xsd">
    <Link rel="down" href="https://api.vcd.portal.skyscapecloud.com/api/org/" type="application/vnd.vmware.vcloud.orgList+xml"/>
    <Link rel="remove" href="https://api.vcd.portal.skyscapecloud.com/api/session"/>
    <Link rel="down" href="https://api.vcd.portal.skyscapecloud.com/api/admin/" type="application/vnd.vmware.admin.vcloud+xml"/>
    <Link rel="down" href="https://api.vcd.portal.skyscapecloud.com/api/org/31ba517c-d0d5-425d-aa1b-088ec84d01c9" name="1-1-11-4b5e8b" type="application/vnd.vmware.vcloud.org+xml"/>
    <Link rel="down" href="https://api.vcd.portal.skyscapecloud.com/api/query" type="application/vnd.vmware.vcloud.query.queryList+xml"/>
    <Link rel="entityResolver" href="https://api.vcd.portal.skyscapecloud.com/api/entity/" type="application/vnd.vmware.vcloud.entity+xml"/>
    <Link rel="down:extensibility" href="https://api.vcd.portal.skyscapecloud.com/api/extensibility" type="application/vnd.vmware.vcloud.apiextensibility+xml"/>
</Session>
```

Querying Storage Profile Usage
-------
Having authenticated, you need to copy the value returned in the x-vcloud-authorization header and use it in all further API requests.
```
> curl -H "x-vcloud-authorization: a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6" -H "Accept: application/*+xml;version=5.6" -i  https://api.vcd.portal.skyscapecloud.com/api/query?type=orgVdcStorageProfile
HTTP/1.1 200 OK
Date: Wed, 06 Jan 2016 14:31:16 GMT
X-VMWARE-VCLOUD-REQUEST-ID: cb955d28-d948-4258-9060-383b2d2531fc
X-VMWARE-VCLOUD-REQUEST-EXECUTION-TIME: 227
Date: Wed, 06 Jan 2016 14:31:16 GMT
Content-Type: application/vnd.vmware.vcloud.query.records+xml;version=5.6
Vary: Accept-Encoding, User-Agent
Connection: close

<?xml version="1.0" encoding="UTF-8"?>
<QueryResultRecords xmlns="http://www.vmware.com/vcloud/v1.5" name="orgVdcStorageProfile" page="1" pageSize="25" total="1" href="https://api.vcd.portal.skyscapecloud.com/api/query?type=orgVdcStorageProfile&amp;page=1&amp;pageSize=25&amp;format=records" type="application/vnd.vmware.vcloud.query.records+xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/vcloud/v1.5 http://10.10.6.14/api/v1.5/schema/master.xsd">
    <Link rel="alternate" href="https://api.vcd.portal.skyscapecloud.com/api/query?type=orgVdcStorageProfile&amp;page=1&amp;pageSize=25&amp;format=references" type="application/vnd.vmware.vcloud.query.references+xml"/>
    <Link rel="alternate" href="https://api.vcd.portal.skyscapecloud.com/api/query?type=orgVdcStorageProfile&amp;page=1&amp;pageSize=25&amp;format=idrecords" type="application/vnd.vmware.vcloud.query.idrecords+xml"/>
    <OrgVdcStorageProfileRecord isDefaultStorageProfile="true" isEnabled="true" isVdcBusy="false" name="BASIC-Any" numberOfConditions="1" storageLimitMB="512000" storageUsedMB="65536" vdc="https://api.vcd.portal.skyscapecloud.com/api/vdc/2f045f74-b487-4231-8c38-a95011b06b10" vdcName="DevOps Demo Env (IL2-TRIAL-BASIC)" href="https://api.vcd.portal.skyscapecloud.com/api/vdcStorageProfile/7a2e654b-84dd-4a09-813e-ef16c90f6907"/>
</QueryResultRecords>
```
Your storage profile usage is in the returned OrgVdcStorageProfileRecord in the properties: **storageLimitMB="512000" storageUsedMB="65536"** 
