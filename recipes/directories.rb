#
# Cookbook Name:: base2
# Recipe:: directories
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

base2_opt_dir = '/opt/base2'
base2_opt_dir_extras = ["archive", "backups", "config", "bin", "scripts"]
base2_opt_local_dirs = ['/etc/ciinabox-metrics','/opt/base2/bin','/opt/base2/ciinabox-metrics']

# Base optional directory
directory base2_opt_dir do
  mode 00755
  owner 'root'
  group 'root'
  action :create
end

# Optional directory extras
base2_opt_dir_extras.each do |dir|
  log "Creating optional extra directory '#{dir.to_s}'..."
  directory "#{base2_opt_dir}/#{dir}" do
    mode 00755
    owner 'root'
    group 'root'
    action :create
  end
end

base2_opt_local_dirs.each do |dir|
  remote_directory dir do
    # Remove starting slash '/'
    source dir[1..-1]
    # All files are owned by root by default, use permissions configuration to change
    owner 'root'
    group 'root'
    mode '0600'
    action :create
  end
end
