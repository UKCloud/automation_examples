#
# Cookbook Name:: my_web_app
# Recipe:: load_balancer
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
# This recipe will be run on the load balancer server instances and will configure 
# Haproxy to distribute requests to the backend webservers.
#

include_recipe 'haproxy-ng::install'
include_recipe 'haproxy-ng::service'

selinux_policy_boolean 'haproxy_connect_any' do
    value true
end

haproxy_defaults 'HTTP' do
  mode 'http'
  config [
    'log global',
    'option httplog',
    'option dontlognull',
    'option forwardfor',
    'option http-server-close',
    'timeout connect 5s',
    'timeout client 500s',
    'timeout server 500s'
  ]
end

webservers = search(:node, "tags:webserver")
webservers.each do |counter|

end
# unless webservers.nil?
# 	node.default['my_web_app']['db_host'] = dbserver['ipaddress']
# end 
nginx_servers = []
search(:node, "tags:webserver").each do |nginx|
  	nginx_servers << {
				      'name' => nginx.name,
				      'address' => nginx['ipaddress'],
				      'port' => 80,
				      'config' => 'check inter 5000 rise 2 fall 5'
				  	}
end

haproxy_backend 'counter' do
  description 'My Counter App'
  mode 'http'
  balance 'roundrobin'
  servers nginx_servers
end

haproxy_frontend 'http' do
  description 'http frontend'
  bind [  "#{node['ipaddress']}:80" ]
  default_backend 'counter'
  use_backends [
    {
      'backend' => 'counter',
      'condition' => ''
    }
  ]
end

haproxy_listen 'stats' do
  mode 'http'
  description 'Haproxy Statistics'

  bind '0.0.0.0:8080'
  config [
  	'log global',
    'maxconn 10',
    'clitimeout 100s',
    'srvtimeout 100s',
    'contimeout 100s',
    'timeout queue 100s',
	'stats enable',
    'stats hide-version',
    'stats refresh 30s',
    'stats show-node',
    'stats realm Haproxy\ Statistics',
    'stats auth admin:password',
    'stats uri /'  ]
end

my_proxies = node['haproxy']['proxies'].map do |p|
  Haproxy::Helpers.proxy(p, run_context)
end

haproxy_instance 'haproxy' do
  config node['haproxy']['config']
  tuning node['haproxy']['tuning']
  proxies my_proxies
end
