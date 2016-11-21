#
# Cookbook Name:: jenkins-server
# Attributes:: default
#
# Copyright 2016 Skyscape Cloud Services
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

default['java']['install_flavor'] = 'oracle'
default['java']['oracle_rpm']['type'] = 'jdk'
default['java']['jdk_version'] = '7'
default['java']['oracle']['accept_oracle_download_terms'] = true

default['jenkins']['master']['install_method'] = 'package'

default['jenkins-server']['plugins'] = ['greenballs', 
										'credentials', 
										'promoted-builds', 
										'delivery-pipeline-plugin', 
										'build-pipeline-plugin',
										'cloudfoundry',
										'saferestart',
										'ghprb',
										'github-pullrequest',
										'github',
										'monitoring',
										'cloudbees-folder',
										'github-oauth']

default['jenkins-server']['github']['oauth_user'] = 'github client id'
default['jenkins-server']['github']['oauth_secret'] = 'github client secret'
