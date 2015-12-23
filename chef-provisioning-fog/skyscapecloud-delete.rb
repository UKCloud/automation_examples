# Run with: chef-client -z skyscapecloud-destroy.rb

require 'chef/provisioning'

with_driver 'fog:Vcair'

num_webservers = 2

machine_batch "internal servers" do
	action :destroy

	machine 'linuxdb01' do
	  tag 'dbserver'
	end

	1.upto(num_webservers) do |i|
		machine "linuxweb#{i}" do
		  tag 'webserver'
		end
	end
end

machine 'jumpbox01' do
	action :destroy
end
