#
# Cookbook Name:: base2
# Recipe:: windows_users
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

node['base2']['windows']['users'].each do |user|

  user "#{user['username']}" do
    password user['password']
  end

  if user['groups']
    user['groups'].each do |group|
      group "#{group}" do
        members [user['username']]
        append true
        action :modify
      end
    end
  end

  windows_home "#{user['username']}" do
    password user['password']
  end

end
