require 'rest-client'
require 'XmlSimple'

begin
	vcloud_session = RestClient::Resource.new('https://api.vcd.portal.skyscapecloud.com/api/sessions', 
											  "#{ENV['VCAIR_USERNAME']}@#{ENV['VCAIR_ORG']}", 
											  ENV['VCAIR_PASSWORD'])
	auth = vcloud_session.post '', :accept => 'application/*+xml;version=5.6'
	auth_token = auth.headers[:x_vcloud_authorization]
rescue => e
  	puts e.response
end

begin
	response = RestClient.get 'https://api.vcd.portal.skyscapecloud.com/api/query', 
								{:params => { :type => 'orgVdcStorageProfile' },													
								 'x-vcloud-authorization' => auth_token,
								 :accept => 'application/*+xml;version=5.6'}
rescue => e
	puts e.response
end

 parsed = XmlSimple.xml_in(response.to_str)

 printf("%15s  %8s  %8s  %8s   %s\n", 'Name', 'Used GB', 'Total GB', 'Percent', 'VDC')
 parsed['OrgVdcStorageProfileRecord'].each do |storage|
	printf("%15s  %8d  %8d  %8.1f%%  %s\n", storage['name'], (storage['storageUsedMB'].to_f / 1024), 
		   (storage['storageLimitMB'].to_f / 1024),
		   (storage['storageUsedMB'].to_f / storage['storageLimitMB'].to_f * 100.0), storage['vdcName']) 	
 end