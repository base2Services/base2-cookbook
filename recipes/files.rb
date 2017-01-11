#
# Cookbook Name:: base2
# Recipe:: metrics
#
# Copyright 2016, base2Services
#


## Install metrics required libraries

node['base2']['files'].each do |file_path|

  cookbook_file file_path do
    source file_path[1..-1]
    user 'root'
    group 'root'
    mode '0755'
    action :create
  end

end