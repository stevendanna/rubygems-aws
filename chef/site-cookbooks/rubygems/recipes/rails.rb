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

run_migrations = false

# Ensure that both the migration role AND the attribute are set before
# we run migrations.
if node['roles'].include?("rubygems_run_migrations") && node['application']['rubygems']['run_migrations']
  run_migrations = true
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
  migrate run_migrations

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
    only_if { node['roles'].include?('rubygems_unicorn') }
  end

  before_symlink do
    ruby_block "remove_run_migrations" do
      block do
        if node.role?("#{app['id']}_run_migrations")
          Chef::Log.info("Migrations were run, removing role[#{app['id']}_run_migrations]")
          node.run_list.remove("role[#{app['id']}_run_migrations]")
        end
      end
    end
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
