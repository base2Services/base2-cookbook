#
# Cookbook Name:: base2
# Recipe:: app
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'base2::default'
include_recipe 'base2::docker'
include_recipe 'base2::codedeploy'
