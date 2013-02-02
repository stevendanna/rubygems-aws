#
# Cookbook Name:: rubygems
# Recipe:: environment_variables
#

app = node.run_state[:app]

if node["roles"].include?("rubygems_redis")
  app["environment_variables"]["REDIS_URL"] = "redis://localhost:6379/0"
else
  redis_ip = search(:node, "roles:rubygems_redis")[0]["redis"]["bind"]
  app["environment_variables"]["REDIS_URL"] = "redis://#{redis_ip}:6379/0"
end

# chef can't deal with an empty file
bash "ensure /etc/environment has content" do
  code %(echo "# touched at `date`" > /etc/environment)
  only_if { File.stat("/etc/environment").size.zero? }
end

ruby_block "setup system ENVIRONMENT variables" do
  block do
    require "chef/util/file_edit"
    file = Chef::Util::FileEdit.new "/etc/environment"

    app['environment_variables'].each do |k, v|
      match = /#{k}/
      kv    = "#{k}=#{v}"

      file.search_file_replace_line(match, kv) # update existing
      file.insert_line_if_no_match(match, kv ) # add new
      file.write_file
    end
  end
end
