#
# Cookbook Name:: my_web_app
# Attributes:: default
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

default['nginx']['default_site_enabled'] = false
default['php-fpm']['user'] = node['nginx']['user']
default['php-fpm']['group'] = node['nginx']['group']

default['mysql']['server_root_password'] = 'secret'

default['my_web_app']['db_user'] = 'counter'
default['my_web_app']['db_password'] = 'secret'
default['my_web_app']['db_name'] = 'counter'

default['haproxy']['install_method'] = 'package'
default['haproxy']['tuning'] = [ 'tune.ssl.default-dh-param 2048' ]
default['haproxy']['config'] = [ 'daemon',
							    'user haproxy',
							    'group haproxy',
							    'pidfile /var/run/haproxy.pid',
							    'log /dev/log    local0',
							    'log /dev/log    local1 notice',
							    'stats socket /var/run/haproxy.sock mode 600 level admin',
							    'stats timeout 2m',
							    'chroot /var/lib/haproxy' ]

default['haproxy']['proxies'] = %w( HTTP http counter stats )
