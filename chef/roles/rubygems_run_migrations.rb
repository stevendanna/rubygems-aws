name "rubygems_run_migrations"
description "Apply this to RubyGems app servers that should run database migrations."
override_attributes("application" => { "rubygems" => { "run_migrations" => true } })
