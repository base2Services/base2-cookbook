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
  package_name = p
  package_version = nil
  # support for both [gemname] and [gemname@version] spec
  if p.include?('@')
    package_name = p.split('@')[0]
    package_version = p.split('@')[1]
  end
  gem_package package_name do
    version package_version unless package_version.nil?
  end
end

execute "Upgrade awscli" do
  command "pip install --upgrade awscli"
  only_if {shell_out("curl -s http://instance-data.ec2.internal").stdout.empty?}
  only_if {shell_out("which pip").stdout.empty?}
end
