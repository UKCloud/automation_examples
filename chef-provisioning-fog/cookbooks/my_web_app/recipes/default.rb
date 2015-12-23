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

log 'Installing my Demo Web Application'

package 'httpd'
package 'php'
package 'php-mysql'

cookbook_file '/var/www/html/index.php' do
  source 'index.php'
  owner 'root'
  group 'root'
  mode '0644'
end

node.default['my_web_app']['db_host'] = '127.0.0.1'
dbserver = search(:node, "tags:dbserver").first
unless dbserver.nil?
	node.default['my_web_app']['db_host'] = dbserver['ipaddress']
end 

template '/var/www/html/config.php' do
  source 'config.php.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables ({ :db_name => 'counter',
  			   :db_host => node['my_web_app']['db_host'],
  			   :db_port => 3306,
  			   :db_user => 'counter',
  			   :db_password => 'secret'})
end
