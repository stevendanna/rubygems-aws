#
# Cookbook:: rubygems
# Recipe:: rails_database
#
# Handles postgresql setup after postgresql server is running

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "rubygems::default"

app                       = node.run_state[:app]
rails_env                 = node.chef_environment =~ /^_default$/ ? "production" : node.chef_environment
rails_root                = app['rails_root']
app_env                   = "#{app['id']}-#{rails_env}"
sudo_name                 = app_env.tr("-", "_").upcase
bundle_cmd                = "bundle"
first_server_name         = app["server_names"][0]
db_name                   = app_env.tr("-", "_")
rails_postgresql_user     = app["id"]

hba_cidr = if attribute?('ec2')
             # ec2 private subnet
             "10.0.0.0/8"
           else
             # assume vagrant?
             "33.33.33.0/8"
           end

node.set['postgresql']['listen_addresses'] = node['ipaddress']
node.set['postgresql']['pg_hba'] = [{
  "type" => "host",
  "db" => db_name,
  "user" => rails_postgresql_user,
  "addr" => hba_cidr,
  "method" => "md5"
}]

# The password is stored in a data bag that is not in the repository.
rails_postgresql_password = node.run_state[:app_secrets]["application"][rails_env]["rails_postgresql_password"]

# create a DB user
pg_user rails_postgresql_user do
  privileges superuser: false, createdb: false, login: true
  password rails_postgresql_password
end

# create a database
pg_database db_name do
  owner app['id']
  encoding "utf8"
  template "template0"
  locale "en_US.UTF8"
end
