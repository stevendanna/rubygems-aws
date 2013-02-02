name "rubygems_db_master"
description "The role for the primary database server for the RubyGems.org app"

run_list(
  "role[base]",
  "recipe[postgresql::server]",
  "recipe[rubygems]",
  "recipe[rubygems::rails_database]"
)

default_attributes(
  # Other postgresql specific attributes are set dynamically in the
  # rubygems::rails_database recipe.
  "postgresql" => {
    "version" => "9.2",
    "ssl" => false,
  },
  "monit" => {
    "monitors" => ["postgresql"]
  }
)
