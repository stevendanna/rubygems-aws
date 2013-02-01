name "base"
description "The base role with required system-level recipes for all nodes"
run_list(
  "recipe[users::sysadmins]",
  "recipe[apt]",
  "recipe[build-essential]",
  "role[system_tools]",
  "role[logging]",
  "role[shell]",
  "role[security]",
  "role[monitoring]",
  "role[mailer]",
  "recipe[emacs]"
)

default_attributes(
  "authorization" => {
    "sudo" => {
      "users" => ["ubuntu"],
      "groups" => ["sysadmin"],
      "passwordless" => true
    }
  },
  "denyhosts" => {
    "admin_email" => "github@phlippers.net",
    "allowed_hosts" => []
  },
  "iptables" => {
    "install_rules" => false
  },
  "logwatch" => {
    "mailto" => "github@phlippers.net"
  },
  "monit" => {
    "monitors" => ["cron", "filesystem", "ntp", "postfix"]
  },
  "ntp" => {
    "is_server" => false,
    "servers" => [
      "0.pool.ntp.org",
      "1.pool.ntp.org",
      "2.pool.ntp.org",
      "3.pool.ntp.org"
    ]
  },
  "openssh" => {
    "server" => {
      "password_authentication" => "no",
      "permit_root_login" => "no",
      "subsystem" => "sftp internal-sftp"
    }
  },
  "postfix" => {
    "aliases" => {
      "root" => "github@phlippers.net"
    }
  },
  "resolver" => {
    "search" => "rubygem.org",
    "nameservers" => ["8.8.8.8", "8.8.4.4"]
  }
)
