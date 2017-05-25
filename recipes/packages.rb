#
# Cookbook Name:: base2
# Recipe:: packages
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

#apt?

if node['platform_family'] == 'rhel' and node['platform'] != 'amazon'
  include_recipe 'yum-epel'
elsif node['platform_family'] == 'debian'
  include_recipe 'apt'
end

node['common']['packages'].each do |p|
  package p
end

node['common']['gems'].each do |p|
  gem_package p
end

execute "Upgrade awscli" do
  command "pip install --upgrade awscli"
  only_if "curl -s http://instance-data.ec2.internal"
  only_if "which pip"
end
