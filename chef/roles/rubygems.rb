name "rubygems"
description "The role with rails application recipes for rubygems"

run_list(
  "role[base]",
  "recipe[git]",
  "recipe[nginx::server]",
  "recipe[nodejs]",
  "recipe[postgresql::libpq]",
  "recipe[rubygems::environment_variables]",
  "recipe[rubygems::monit]",
  "recipe[rubygems::rails]",
  "recipe[rubygems::rails_nginx]"
)

default_attributes(
  # application data is in the apps/rubygems data bag
)
