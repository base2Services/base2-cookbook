#
# Cookbook Name:: base2
# Recipe:: bootstrap
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

log 'Bootstrap role not set please ensure your instances are tagged correctly' do
  level :warn
  only_if { node['base2']['role'].nil? }
end

log "Running Bootstrap for #{node['base2']['role']}" do |variable|
  level :info
  not_if { node['base2']['role'].nil? }
end

include_recipe "#{node['base2']['role']}" if !node['base2']['role'].nil?
