#

knife ec2 server create \
    -x ubuntu \
    -S someara_opscode \
    -f m1.large \
    -I ami-d726abbe \
    -r 'role[rubygems_db_master],role[rubygems_redis]'

knife ec2 server create \
    -x ubuntu \
    -S someara_opscode \
    -f m1.large \
    -I ami-d726abbe \
    -r 'role[rubygems_memcached],role[rubygems],role[rubygems_unicorn],role[rubygems_run_migrations]'
  
knife ec2 server create \
    -x ubuntu \
    -S someara_opscode \
    -f m1.large \
    -I ami-d726abbe \
   -r 'role[rubygems_memcached],role[rubygems],role[rubygems_unicorn]'

knife ec2 server create \
    -x ubuntu \
    -S someara_opscode \
    -f m1.large \
    -I ami-d726abbe \
    -r 'role[balancer]'
