name "fullstack"
description "The role which contains all cookbooks for a 'full-stack' server."
run_list(
  "role[base]",
  "role[rubygems_memcached]",
  "recipe[redis::server]",
  "recipe[postgresql::server]",
  "role[rubygems]",
  "role[balancer]"
)
