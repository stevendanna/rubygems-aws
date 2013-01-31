name "almost_fullstack"
description "Servers for running the entire RubyGems.org application stack sans load balancer"

run_list(
  "role[base]",
  "role[rubygems_memcached]",
  "role[rubygems_redis]",
  "role[rubygems_db_master]",
  "role[rubygems]"
)
