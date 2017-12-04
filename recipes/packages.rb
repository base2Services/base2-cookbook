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

# Install and purge Amazon specific packages
if platform_family('amazon')

  node['common']['amzn']['install'].each do |p|
    yum_package p
  end

  node['common']['yum']['purge'].each do |p|
    yum_package p do
      action :purge
    end
  end

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
  only_if "curl -s http://instance-data.ec2.internal"
  only_if "which pip"
end
