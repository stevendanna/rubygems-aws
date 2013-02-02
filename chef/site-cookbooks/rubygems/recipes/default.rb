#
# Cookbook Name:: rubygems
# Recipe:: default

# Load the data bags once, then store them in the node's run state so
# they can be used in multiple recipes. Save the application data to
# the node as an attribute.
app = data_bag_item(:apps, "rubygems")
app_secrets = data_bag_item(:secrets, "rubygems")
node.run_state[:app] = app.to_hash
node.run_state[:app_secrets] = app_secrets.to_hash
node.set['application'] = node.run_state[:app]
node.save
