current_dir = File.dirname(__FILE__)
chef_dir = File.expand_path('~/.chef')
log_level                :info
log_location             STDOUT
node_name                "#{ENV['username']}"
client_key               "#{chef_dir}/#{ENV['username']}.pem"
validation_client_name   "#{ENV['chef_org_name']}-validator"
validation_key           "#{chef_dir}/#{ENV['chef_org_name']}-validator.pem"
chef_server_url          "https://api.chef.io/organizations/#{ENV['chef_org_name']}"
cookbook_path            ["#{current_dir}/cookbooks"]

knife[:vcair_api_host] = 'api.vcd.portal.skyscapecloud.com'
knife[:vcair_username] = "#{ENV['VCAIR_USERNAME']}"
knife[:vcair_password] = "#{ENV['VCAIR_PASSWORD']}"
knife[:vcair_org]      = "#{ENV['VCAIR_ORG']}"
knife[:vcair_net]      = "Jumpbox Network"
# knife[:vcair_show_progress] = true