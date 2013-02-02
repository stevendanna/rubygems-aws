server "33.33.33.10", :app, :web
server "33.33.33.11", :lb
server "33.33.33.12", :db

#set :server_ip, "33.33.33.10"
set :user, 'vagrant'
set :id_file, "#{ENV['HOME']}/.vagrant.d/insecure_private_key"
ssh_options[:keys] = [id_file]
set :environment_name, "vagrant"
set :node_name, "vagrant"

set :chef_binary, "/usr/bin/chef-solo"
