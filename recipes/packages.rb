#
# Cookbook Name:: base2
# Recipe:: packages
#
# Copyright (C) 2014 base2Services
# 
# All rights reserved - Do Not Redistribute
#

common_packages = node['common']['packages']


case node['platform_family']
when 'debian'
  os_packages = %w(nagios-nrpe-server nagios-plugins)
  include_recipe 'apt'
when 'rhel'
  os_packages = %w(nagios-plugins-all nagios-plugins-nrpe nrpe)
  # yum epel repository is required for php-pecl-imagick
  include_recipe 'yum-epel' if node['platform'] != 'amazon' 
end

common_packages.concat os_packages

# dependencies
common_packages.each do |p|
  package p
end


execute "Upgrade awscli" do
  command "pip install --upgrade awscli"
  only_if "which pip"
end