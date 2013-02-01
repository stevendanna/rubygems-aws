#
# Cookbook Name:: rubygems
# Recipe:: rails_nginx
#

include_recipe "rubygems::default"

app_env = "#{node["application"]["name"]}-#{node["application"]["rails_env"]}"

# ssl certificates directory
directory "#{node["nginx"]["dir"]}/certs" do
  owner "root"
  group "root"
  mode  "0644"
  action :create
end

# ssl certificate key
cookbook_file "#{node["nginx"]["dir"]}/certs/#{node["application"]["ssl_key"]}" do
  source node["application"]["ssl_key"]
  owner  "root"
  group  "root"
  mode   "0644"
  notifies :reload, "service[nginx]", :immediately
end

# ssl certificate
cookbook_file "#{node["nginx"]["dir"]}/certs/#{node["application"]["ssl_cert"]}" do
  source node["application"]["ssl_cert"]
  owner  "root"
  group  "root"
  mode   "0644"
  notifies :reload, "service[nginx]", :immediately
end

Chef::Log.info("DEBUG: nginx dir: #{node["nginx"]["dir"]}")
Chef::Log.info("DEBUG: application ssl_key: #{node["application"]["ssl_key"]}")

# vhost configuration
template "#{node["nginx"]["dir"]}/sites-available/#{app_env}-balancer.conf" do
  source "nginx_balancer.conf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  action :create
  variables(
    name:         node["application"]["name"],
    rails_env:    node["application"]["rails_env"],
    rails_root:   node["application"]["rails_root"],
    app_server:   node["application"]["app_server"],
    server_names: node["application"]["server_names"],
    use_ssl:      node["application"]["use_ssl"],
    force_ssl:    node["application"]["force_ssl"],
    ssl_key:      File.join(node["nginx"]["dir"], "certs", node["application"]["ssl_key"]),
    ssl_cert:     File.join(node["nginx"]["dir"], "certs", node["application"]["ssl_cert"]),
    nginx_dir:    node["nginx"]["dir"]
  )
  notifies :reload, "service[nginx]", :immediately
end



# symlink to sites-enabled
link "#{node["nginx"]["dir"]}/sites-enabled/#{app_env}-balancer.conf" do
  to "#{node["nginx"]["dir"]}/sites-available/#{app_env}-balancer.conf"
  notifies :reload, "service[nginx]", :immediately
end
