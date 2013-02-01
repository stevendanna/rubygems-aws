#
# Cookbook Name:: rubygems
# Recipe:: rails
#
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

app                       = node.run_state[:app]
rails_env                 = node.chef_environment =~ /^_default$/ ? "production" : node.chef_environment
rails_root                = app['rails_root']
app_env                   = "#{app['id']}-#{rails_env}"
sudo_name                 = app_env.tr("-", "_").upcase
bundle_cmd                = "bundle"
first_server_name         = app["server_names"][0]
db_name                   = app_env.tr("-", "_")
rails_postgresql_user     = app["id"]

if node['roles'].include?("rubygems_db_master")
  rails_postgresql_password = node['application']["rails_postgresql_password_#{rails_env}"]
else
  rails_postgresql_password = search(:node, "roles:rubygems_db_master")[0]['application']["rails_postgresql_password_#{rails_env}"]
end

# application directory
directory "/applications/#{app['id']}" do
  owner  "deploy"
  group  "deploy"
  action :create
  recursive true
end


application "rubygems" do
  path app['rails_root']
  repository app['repository']
  revision app['revision']
  owner "deploy"
  group "deploy"
  packages %w{libpq-dev}
  migrate true

  r = rails do
    gems %w{bundler}
    bundle_command "/usr/local/bin/bundle"
    database_template "database.yml.erb"
    database_master_role "rubygems_db_master"
    database do
      adapter "postgresql"
      database db_name
      username app['id']
      password rails_postgresql_password
    end
  end
  r.cookbook_name = "rubygems"

  unicorn do
    port "3000"
    bundler true
    bundle_command "/usr/local/bin/bundle"
  end
end

# logrotate for application
template "/etc/logrotate.d/#{app_env}" do
  source "logrotate-application.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  action :create
  variables(service_name: app_env, rails_root: rails_root)
end
