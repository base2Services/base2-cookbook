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
