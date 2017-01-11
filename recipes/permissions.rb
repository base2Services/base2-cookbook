#
# Cookbook Name:: base2
# Recipe:: permissions
#
# Copyright (C) 2016 base2Services
#
# All rights reserved - Do Not Redistribute
#

if node['base2']['permissions']['directory']

  node['base2']['permissions']['directory'].each do |dir, dir_conf|

    # Using chown and chmod, rathern than directory resource in order to have deep recursion
    execute "alter-permissions" do
      command "chown -R #{dir_conf['user']}:#{dir_conf['group']} #{dir} && chmod -R #{dir_conf['mode']} #{dir}"
      user "root"
      action :run
    end

  end
end