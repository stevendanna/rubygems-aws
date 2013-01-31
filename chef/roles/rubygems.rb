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
  "application" => {
    "name" => "rubygems",
    "repository" => "https://github.com/rubygems/rubygems.org.git",
    "rails_env" => "staging",
    "rails_root" => "/applications/rubygems/staging",
    "server_names" => ["rubygems.phlippers.net"],
    "use_ssl" => true,
    "force_ssl" => true,
    "ssl_key" => "dev.rubygems.org.key",
    "ssl_cert" => "dev.rubygems.org.crt",
    "app_server" => {
      "name" => "thin",
      "concurrency" => 4
    }
  },
  "environment_variables" => {
    "RAILS_ENV" =>  "staging",
    "RACK_ENV" =>   "staging",
    "REDIS_URL" =>  "redis://localhost:6379/0",

    "TMOUT" => "600"

    # // Ruby GC tuning
    # // "RUBY_HEAP_MIN_SLOTS" => 1000000,
    # // "RUBY_HEAP_SLOTS_INCREMENT" => 1000000,
    # // "RUBY_HEAP_SLOTS_GROWTH_FACTOR" => 1,
    # // "RUBY_GC_MALLOC_LIMIT" => 1000000000,
    # // "RUBY_HEAP_FREE_MIN" => 500000,
    # // "RUBY_FREE_MIN" => 500000
  },

  "set_fqdn" => "rubygems.phlippers.net"
)
