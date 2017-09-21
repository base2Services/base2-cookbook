#
# Cookbook Name:: base2
# Recipe:: default
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

case node['platform_family']
when 'windows'
  include_recipe 'base2::windows'
  include_recipe 'base2::windows_directories'
  include_recipe 'base2::windows_users'
  include_recipe 'base2::windows_security'
else
  include_recipe 'os-hardening' if node['base2']['os-hardening']
  include_recipe 'base2::directories'
  include_recipe 'base2::packages'
  include_recipe 'base2::users'
  include_recipe 'base2::environment'
  include_recipe 'base2::nrpe'
end
