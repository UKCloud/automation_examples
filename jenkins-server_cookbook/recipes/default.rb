#
# Cookbook Name:: jenkins-server
# Recipe:: default
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

include_recipe 'yum-epel'

%w(htop atop iftop git).each do |p|
	package p do
	  action :install
	end
end

include_recipe 'java'
include_recipe 'jenkins::master'

node['jenkins-server']['plugins'].each do |plugin|
	jenkins_plugin plugin do
		action :install
		notifies :restart, 'service[jenkins]', :immediately
	end
end

jenkins_script 'add_authentication' do
  action :nothing
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    import org.jenkinsci.plugins.*

    String githubWebUri = 'https://github.com'
    String githubApiUri = 'https://api.github.com'
    String clientID = '${node['jenkins-server']['github']['oauth_user']}'
    String clientSecret = '${node['jenkins-server']['github']['oauth_secret']}'
    String oauthScopes = 'read:org,user:email'

    SecurityRealm github_realm = new GithubSecurityRealm(githubWebUri, githubApiUri, clientID, clientSecret, oauthScopes)
    //check for equality, no need to modify the runtime if no settings changed
    if(!github_realm.equals(Jenkins.instance.getSecurityRealm())) {
        Jenkins.instance.setSecurityRealm(github_realm)
        Jenkins.instance.save()
    }
  EOH
end

jenkins_script 'add_authorization' do
  action :nothing
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    import org.jenkinsci.plugins.*

    //permissions are ordered similar to web UI
    //Admin User Names
    String adminUserNames = 'robcoward'
    //Participant in Organization
    String organizationNames = 'skyscape-cloud-services'
    //Use Github repository permissions
    boolean useRepositoryPermissions = true
    //Grant READ permissions to all Authenticated Users
    boolean authenticatedUserReadPermission = false
    //Grant CREATE Job permissions to all Authenticated Users
    boolean authenticatedUserCreateJobPermission = false
    //Grant READ permissions for /github-webhook
    boolean allowGithubWebHookPermission = false
    //Grant READ permissions for /cc.xml
    boolean allowCcTrayPermission = false
    //Grant READ permissions for Anonymous Users
    boolean allowAnonymousReadPermission = false
    //Grant ViewStatus permissions for Anonymous Users
    boolean allowAnonymousJobStatusPermission = true

    AuthorizationStrategy github_authorization = new GithubAuthorizationStrategy(adminUserNames,
        authenticatedUserReadPermission,
        useRepositoryPermissions,
        authenticatedUserCreateJobPermission,
        organizationNames,
        allowGithubWebHookPermission,
        allowCcTrayPermission,
        allowAnonymousReadPermission,
        allowAnonymousJobStatusPermission)

    //check for equality, no need to modify the runtime if no settings changed
    if(!github_authorization.equals(Jenkins.instance.getAuthorizationStrategy())) {
        Jenkins.instance.setAuthorizationStrategy(github_authorization)
        Jenkins.instance.save()
    }
  EOH
end