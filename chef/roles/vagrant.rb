name "vagrant"
description "The base vagrant role with a few overrides"

override_attributes(
  "authorization" => {
    "sudo" => {
      "passwordless" => true
    }
  },
  "sudo" => {
    "add_vagrant" => true
  },
  "application" => {
   "application_servers" => [ "33.33.33.10" ],
   "database_server" => "33.33.33.12"
  },
  "postgresql" => {
    "users" => [{ "username" => "rubygems",
                  "superuser" => false,
                  "createdb" => false,
                  "login" => true,
                  "password" => "nrpnspo9465r88nqs20s3nqo120q3snn" }
               ],
    "databases" => [{ "name" => "rubygems_staging",
                      "owner" => "rubygems",
                      "encoding" => "utf8",
                      "template" => "template0",
                      "locale" => "en_US.UTF8"
                    }],
    "version" => "9.2",
    "data_directory" => "/var/lib/postgresql/9.2/main",
    "listen_addresses" => "33.33.33.12",
    "ssl" => false,
    "work_mem" => "100MB",
    "shared_buffers" => "24MB",
    "pg_hba" => [{                                    "type" => "host",
                                     "db" => "rubygems_staging",
                                     "user" => "rubygems",
                                     "addr" => "33.33.33.10/0",
                                     "method" => "md5"
                                   }
    ]
  }
)
