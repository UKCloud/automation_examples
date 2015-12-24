# Run with: chef-client -z skyscapecloud-demo.rb

require 'chef/provisioning'

with_driver 'fog:Vcair'

num_webservers = 2

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
  ssh_gateway: "#{ENV['VCAIR_SSH_USERNAME']}@#{ENV['JUMPBOX_IPADDRESS']}",
  ssh_options: { 
    :password => ENV['VCAIR_SSH_PASSWORD'],
  }
}

machine 'jumpbox01' do
  tag 'jumpbox'
  machine_options vcair_opts
end

machine 'linuxdb01' do
  tag 'dbserver'
  role 'dbserver'
  machine_options vcair_opts.merge({ memory: '4096', cpus: '2' })
end

machine_batch "internal servers" do
	1.upto(num_webservers) do |i|
		machine "linuxweb#{i}" do
		  tag 'webserver'
      role 'webserver'
		  machine_options vcair_opts.merge({ memory: '2048'})
		end
	end
end