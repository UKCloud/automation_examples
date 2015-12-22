# Run with: chef-client -z skyscapecloud-demo.rb

require 'chef/provisioning'

num_webservers = 2

with_driver 'fog:Vcair'

with_chef_server "https://api.chef.io/organizations/#{ENV['chef_org_name']}",
		:client_name => Chef::Config[:node_name],
		:signing_key_filename => Chef::Config[:client_key]

vcair_opts = {
  bootstrap_options: {
    image_name: 'centos71',
    net: 'Jumpbox Network',
    memory: '512',
    cpus: '1',
    ssh_options: {
      password: ENV['VCAIR_SSH_PASSWORD'],
      user_known_hosts_file: '/dev/null',

    }
  },
  create_timeout: 600,
  start_timeout: 600,
  ssh_gateway: "vagrant@#{ENV['JUMPBOX_IPADDRESS']}",
  ssh_options: { 
    :password => ENV['VCAIR_SSH_PASSWORD'],
  }
}

machine 'jumpbox01' do
  tag 'jumpbox'
  # recipe 'apache2'
  machine_options vcair_opts
end

machine_batch "internal servers" do

	machine 'linuxdb01' do
	  tag 'dbserver'
	  # recipe 'postgresql'
	  machine_options vcair_opts.merge({ memory: '4096', cpus: '2' })
	end

	1.upto(num_webservers) do |i|
		machine "linuxweb#{i}" do
		  tag 'webserver'
		  # recipe 'postgresql'
		  machine_options vcair_opts.merge({ memory: '2048'})
		end
	end
end