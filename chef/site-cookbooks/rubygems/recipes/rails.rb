#
# Cookbook Name:: rubygems
# Recipe:: rails
#

app                       = node.run_state[:app]
rails_env                 = node.chef_environment =~ /^_default$/ ? "production" : node.chef_environment
rails_root                = app['rails_root']
app_env                   = "#{app['id']}-#{rails_env}"
sudo_name                 = app_env.tr("-", "_").upcase
bundle_cmd                = "bundle"
first_server_name         = app["server_names"][0]
db_name                   = app_env.tr("-", "_")
rails_postgresql_user     = app["id"]
rails_postgresql_password = Digest::MD5.hexdigest(app_env.reverse).reverse.tr("A-Za-z", "N-ZA-Mn-za-m")

node.set["application"]["rails_postgresql_password_#{rails_env}"] = rails_postgresql_password
node.save

# application directory
directory "/applications/#{app['id']}" do
  owner  "deploy"
  group  "deploy"
  action :create
  recursive true
end

Chef::Log.info("app: #{app}")
Chef::Log.info("rails_env: #{rails_env}")
Chef::Log.info("rails_root: #{rails_root}")
Chef::Log.info("app_env: #{app_env}")
Chef::Log.info("db_name: #{db_name}")
Chef::Log.info("rails_postgresql_user: #{rails_postgresql_user}")
Chef::Log.info("rails_postgresql_password: #{rails_postgresql_password}")

# create a DB user
pg_user rails_postgresql_user do
  privileges superuser: false, createdb: false, login: true
  password node['application']['rails_postgresql_password_#{rails_env}']
end

# create a database
pg_database db_name do
  owner rails_postgresql_user
  encoding "utf8"
  template "template0"
  locale "en_US.UTF8"
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
    database do
      adapter "postgresql"
      database db_name
      username rails_postgresql_user
      password rails_postgresql_password
      host "localhost"
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
