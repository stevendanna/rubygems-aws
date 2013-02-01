name "rubygems_db_master"
description "The role for the primary database server for the RubyGems.org app"

run_list(
  "role[base]",
  "recipe[postgresql::server]",
  "recipe[rubygems]",
  "recipe[rubygems::rails_database]"
)

default_attributes(
  "postgresql" => {
    "listen_addresses" => "0.0.0.0",
    "version" => "9.2",
    "ssl" => false,
    "pg_hba" => [
      "host rubygems_production rubygems 127.0.0.1/32 password"
    ]
  },
  "monit" => {
    "monitors" => ["postgresql"]
  }
)
