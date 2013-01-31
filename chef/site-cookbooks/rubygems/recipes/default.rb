#
# Cookbook Name:: rubygems
# Recipe:: default

app = data_bag_item(:apps, "rubygems")
node.run_state[:app] = app.to_hash
node.set['application'] = node.run_state[:app]
node.save
