#
# Cookbook Name:: base2
# Attribute:: default
#
# Copyright (C) 2014 base2Services
# 
# All rights reserved - Do Not Redistribute
#

default['system']['timezone'] = "Australia/Melbourne"
default['common']['packages'] = ['telnet', 'mc', 'screen', 'sysstat','aws-amitools-ec2','aws-apitools-common','aws-cfn-bootstrap','cloud-init' ]
default['common']['user'] = 'base2'