# Run with: chef-client -z skyscapecloud-destroy.rb

require 'chef/provisioning'

with_driver 'fog:Vcair'

num_webservers = 2

with_chef_server "https://api.chef.io/organizations/#{ENV['chef_org_name']}",
		:client_name => Chef::Config[:node_name],
		:signing_key_filename => Chef::Config[:client_key]

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
