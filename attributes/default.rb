#
# Cookbook Name:: base2
# Attribute:: default
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

default['system']['timezone'] = "Australia/Melbourne"
default['common']['packages'] = ['telnet', 'mc', 'screen', 'sysstat','traceroute']
default['common']['user'] = 'base2'

default['base2']['docker']['images'] = []

default['base2']['environment']['name'] = 'default'
default['base2']['environment']['type'] = 'dev'
default['base2']['role'] = 'app'

default['base2']['codedeploy_region'] = 'us-west-2'
default['base2']['ssm_agent'] = 'false'

default['base2']['docker_version'] = '1.9.1'
default['base2']['docker_checksum'] = '52286a92999f003e1129422e78be3e1049f963be1888afc3c9a99d5a9af04666'
