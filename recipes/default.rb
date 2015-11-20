#
# Cookbook Name:: base2
# Recipe:: default
#
# Copyright (C) 2014 base2Services
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "base2::directories"
include_recipe "base2::packages"
include_recipe "base2::users"
include_recipe "base2::environment"
include_recipe "base2::nrpe"
