name "fullstack"
description "Servers for running the entire RubyGems.org application stack"
run_list(
  "role[base]",
  "role[rubygems_memcached]",
  "role[rubygems_redis]",
  "role[rubygems_db_master]",
  "role[rubygems]",
  "role[rubygems_lb]"
)
