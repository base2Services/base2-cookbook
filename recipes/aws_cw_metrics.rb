#
# Cookbook Name:: Base2
# Recipe:: metrics
#
# Copyright (C) 2016 base2Services
#
# All rights reserved - Do Not Redistribute
#


# 1 - copy directories and files

metric_dirs = ['/etc/ciinabox-metrics','/opt/base2/ciinabox-metrics']

metric_dirs.each do |dir|
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


cookbook_file '/etc/profile.d/env_path.sh' do
  source 'etc/profile.d/env_path.sh'
  user 'root'
  group 'root'
  mode '0755'
  action :create
end

# 2 - install package dependencies

if node['platform_family'] == 'rhel' and node['platform'] != 'amazon'
  include_recipe 'yum-epel'
elsif node['platform_family'] == 'debian'
  include_recipe 'apt'
end

package 'rubygem-io-console' do
  action :install
end

# 3 - users

log "Creating the ciinabox-metrics user..."
user 'ciinabox-metrics' do
  shell '/bin/bash'
  home "/home/ciinabox-metrics"
  manage_home true
  action :create
end


# 4 - permissions
directory_permissions = {}
directory_permissions['/opt/base2/ciinabox-metrics'] = {}
directory_permissions['/etc/ciinabox-metrics'] = {}

directory_permissions['/opt/base2/ciinabox-metrics']['user'] = 'ciinabox-metrics'
directory_permissions['/opt/base2/ciinabox-metrics']['group'] = 'ciinabox-metrics'
directory_permissions['/opt/base2/ciinabox-metrics']['mode'] = '755'

directory_permissions['/etc/ciinabox-metrics']['user'] = 'ciinabox-metrics'
directory_permissions['/etc/ciinabox-metrics']['group'] = 'ciinabox-metrics'
directory_permissions['/etc/ciinabox-metrics']['mode'] = '755'

directory_permissions.each do |dir, dir_conf|

  # Using chown and chmod, rathern than directory resource in order to have deep recursion
  execute "alter-permissions" do
    command "chown -R #{dir_conf['user']}:#{dir_conf['group']} #{dir} && chmod -R #{dir_conf['mode']} #{dir}"
    user "root"
    action :run
  end

end

# 5 - install dependencies

metrics_dependencies = ['bundler', 'rake', 'whenever']

metrics_dependencies.each do |gem_name|
  gem_package gem_name do
    gem_binary '/usr/bin/gem'
    options '--no-user-install'
    action [:install,:upgrade]
  end
end


ciinabox_metrics_env = {'PATH' => '/bin:/usr/bin:/usr/local/bin',
                        'HOME' => '/home/ciinabox-metrics',
                        'USER' => 'ciinabox-metrics',
                        'USERNAME' => 'ciinabox-metrics'}

## Setup tasks

# Install metric gems
bash "install-metrics-gems" do
  code "bundle install"
  environment ciinabox_metrics_env
  cwd "/opt/base2/ciinabox-metrics"
  user "ciinabox-metrics"
  action :run
end


# 6 - install crontab

# Setup cron
bash "install-metrics-cron" do
  code "bundle exec rake ciinabox:install_metrics_cron"
  environment ciinabox_metrics_env
  cwd "/opt/base2/ciinabox-metrics"
  user "ciinabox-metrics"
  action :run
end