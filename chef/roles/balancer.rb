name "balancer"
description "The role which contains all cookbooks for a load balancer."
run_list(
  "role[base]",
  "recipe[rubygems::nginx_source]",
  "recipe[rubygems::balancer]"
)

override_attributes(
  "nginx" => {
    "geoip" => true,
    "enable_stub_status" => false,
    "dir" => "/opt/nginx/conf"
  }
)
