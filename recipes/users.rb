#
# Cookbook Name:: base2
# Recipe:: users
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

node['base2']['users'].each do |account, ssh_keys|

  log "Creating the '#{account}' user..."
  user "#{account}" do
    shell '/bin/bash'
    home "/home/#{account}"
    supports :manage_home => true
    action :create
  end

  # SSH dir
  directory "/home/#{account}/.ssh" do
    owner account
    group account
    mode 00700
    action :create
  end

  file "/home/#{account}/.ssh/authorized_keys" do
    content "#generated and managed by chef\n"
    owner account
    group account
    mode '0600'
    action :create
  end

  ssh_keys.each do |key|
    execute 'append_authorized_keys' do
      command "echo \"#{key}\" >> /home/#{account}/.ssh/authorized_keys"
      action :run
    end
  end

  file "/etc/sudoers.d/#{account}" do
    content "#{account} ALL = NOPASSWD: ALL"
    owner 'root'
    group 'root'
    mode '0600'
    action :create
  end

end
