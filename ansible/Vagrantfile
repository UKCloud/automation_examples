# -*- mode: ruby -*-
# vi: set ft=ruby :

if Gem::Version.new(::Vagrant::VERSION) < Gem::Version.new('1.5')
  Vagrant.require_plugin('vagrant-hostmanager')
end

$script = <<SCRIPT
yum -y install epel-release
yum -y install ansible
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "boxcutter/centos72"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define "ansible" do |server|
	server.vm.hostname = 'ansible'
    server.vm.network "private_network", ip: "192.168.33.10" #, nic_type: "virtio"
	server.hostmanager.aliases = %w(ansible.example.com)

    server.vm.provision "shell", inline: $script
    server.vm.synced_folder ".", "/home/vagrant/playbooks", type: 'virtualbox'

    server.vm.provider "virtualbox" do |v|
      #v.gui = true
    end
  end


end
