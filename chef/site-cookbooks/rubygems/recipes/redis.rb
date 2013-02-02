#
# Cookbook:: rubygems
# Recipe:: redis

# Set the redis bind address to the node's primary IP address
node.set['redis']['bind'] = node['ipaddress']
