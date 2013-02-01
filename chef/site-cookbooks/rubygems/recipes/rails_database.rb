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


# this awkward conditional is to account for not storing plaintext
# passwords in the open source repository. The node attribute will be
# be used in the first part if it exists, and fall back to generating
# a random password (and saving the node to the server).
if node['application'].attribute?("rails_postgresql_password_#{rails_env}")
  rails_postgresql_password = node['application']["rails_postgresql_password_#{rails_env}"]
else
  rails_postgresql_password = secure_password
  node.set_unless["application"]["rails_postgresql_password_#{rails_env}"] = rails_postgresql_password
  node.save
end

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
