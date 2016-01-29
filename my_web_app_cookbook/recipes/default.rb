#
# Cookbook Name:: my_web_app
# Recipe:: default
#
# Copyright 2015 Skyscape Cloud Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This recipe will be run on the web server instances and will configure Nginx, php-fpm
# and deploy the php scripts and templated config file that make up our Web App.
#

include_recipe 'nginx'
include_recipe 'php-fpm'

# Make sure the php mysql extensions are installed.
package 'php-mysqlnd'

package 'policycoreutils-python' do
  action :install
end

# Ensure we have SELinux in enforcing mode
selinux_state "SELinux Enforcing" do
  action :enforcing
end

# Allow http servers (nginx/apache) to write to php-fpm socket
selinux_policy_fcontext '/var/run/php-fpm(.*)?.sock' do
  secontext 'httpd_var_run_t'
end

selinux_policy_boolean 'httpd_can_network_connect_db' do
    value true
end

# Create a nginx site config file
template "#{node['nginx']['dir']}/sites-available/my_web_app.conf" do
  source 'my_web_app.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

nginx_site 'my_web_app.conf' do
  enable true
end

directory '/var/www/my_web_app' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

# Deploy the php files that make up our web application
cookbook_file '/var/www/my_web_app/index.php' do
  source 'index.php'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/var/www/my_web_app/favicon.ico' do
  source 'favicon.ico'
  owner 'root'
  group 'root'
  mode '0644'
end

# Use chef's search functionality to dynamically discover the ip address of the database server
node.default['my_web_app']['db_host'] = '127.0.0.1'
dbserver = search(:node, "tags:dbserver").first
unless dbserver.nil?
	node.default['my_web_app']['db_host'] = dbserver['ipaddress']
end 

template '/var/www/my_web_app/config.php' do
  source 'config.php.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables ({ :db_name => node['my_web_app']['db_name'],
  			   :db_host => node['my_web_app']['db_host'],
  			   :db_port => 3306,
  			   :db_user => node['my_web_app']['db_user'],
  			   :db_password => node['my_web_app']['db_password']})
end

# If no external database servers are found, include the recipe to setup a local db instance
if node['my_web_app']['db_host'] == '127.0.0.1'
  include_recipe 'my_web_app::db_setup'
end
  