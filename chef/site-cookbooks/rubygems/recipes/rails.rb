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

# The password is stored in a data bag that is not in the repository.
# It is loaded into the node's run state in the default recipe.
rails_postgresql_password = node.run_state[:app_secrets]["application"][rails_env]["rails_postgresql_password"]

# Ensure that both the migration role AND the attribute are set before
# we run migrations.
run_migrations = false
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

  r = nginx_load_balancer do
    application_server_role "rubygems_unicorn"
    template "nginx_balancer.conf.erb"
    server_name node["application"]["server_names"] || "rubygems.org"
    application_port node["application"]["internal_port"]
    ssl node["application"]["use_ssl"]
    ssl_certificate ::File.join(node["nginx"]["dir"], "certs", node["application"]["ssl_cert"])
    ssl_certificate_key ::File.join(node["nginx"]["dir"], "certs", node["application"]["ssl_key"])
    only_if { node['roles'].include?('balancer') }
  end
  r.cookbook_name = "rubygems"

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
