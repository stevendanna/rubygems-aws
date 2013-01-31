name "rubygems_lb"
description "Servers that are front end load balancers for the RubyGems.org app"
run_list(
  "role[base]",
  "recipe[nginx::server]",
  "recipe[rubygems::balancer]"
)
