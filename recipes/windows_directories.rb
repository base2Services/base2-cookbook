#
# Cookbook Name:: base2
# Recipe:: windows_directories
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

log 'Running base2 Windows SOE'
  level :info
end

base2_opt_dir = 'C:/base2'
base2_opt_dir_extras = ["archive", "backups", "config", "bin", "scripts"]

# Base optional directory
directory base2_opt_dir do
  action :create
end

# Optional directory extras
base2_opt_dir_extras.each do |dir|
  log "Creating optional extra directory '#{dir.to_s}'..."
  directory "#{base2_opt_dir}/#{dir}" do
    action :create
  end
end

cookbook_file "#{base2_opt_dir}/bin/EC2-Bootstrap.ps1" do
  source "windows/EC2-Bootstrap.ps1"
end
