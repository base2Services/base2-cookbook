#
# Cookbook Name:: base2
# Recipe:: environment
#
# Copyright 2013, base2Services
#

system_timezone = node['system']['timezone']

link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{system_timezone}"
end