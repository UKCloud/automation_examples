#
# Cookbook Name:: my_web_app
# Recipe:: db_setup
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
# This recipe will be run on the database server instance and will configure mysql, create the
# required database and populate it with the correct table, granting a user access to it for
# our Web App to use.
#

mysql2_chef_gem 'default' do
  action :install
end

# Install and configure mysql
mysql_service 'default' do
  bind_address '0.0.0.0'
  port '3306'  
  initial_root_password node['mysql']['server_root_password']
  action [:create, :start]
end

mysql_connection_info = {
  :host     => '127.0.0.1',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

cookbook_file "#{Chef::Config[:file_cache_path]}/dbschema.sql" do
  source 'schema.sql'
  owner 'root'
  group 'root'
  mode '0644'
end

# Create the database and populate its schema with the required tables
mysql_database 'create tables' do
  connection mysql_connection_info
  database_name node['my_web_app']['db_name']
  sql lazy { ::File.open("#{Chef::Config[:file_cache_path]}/dbschema.sql").read }
  action :nothing
end

mysql_database node['my_web_app']['db_name'] do
  connection mysql_connection_info
  action :create
  notifies :query, "mysql_database[create tables]", :immediately
end

# Create a user for our web app to use
mysql_database_user node['my_web_app']['db_user'] do
  connection mysql_connection_info
  password node['my_web_app']['db_password']
  database_name node['my_web_app']['db_name']
  host '%'
  privileges [:select,:update,:insert]
  action :grant
end