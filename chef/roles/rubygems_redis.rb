name "rubygems_redis"
description "Servers that run redis for the RubyGems.org app"

run_list(
  "role[base]",
  "recipe[redis::server]"
)

default_attributes(
  "monit" => {
    "monitors" => ["redis"]
  }
)
