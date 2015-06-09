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

# Base optional directory
directory "#{base2_opt_dir}" do
  mode 00755
  owner 'root'
  group 'root'
  
  action :create
end

# Optional directory extras
base2_opt_dir_extras.each do |dir|
  log "Creating optional extra directory '#{dir.to_s}'..."  
  directory "#{dir}" do
    mode 00755
    owner 'root'
    group 'root'
    
    action :create
  end
end
