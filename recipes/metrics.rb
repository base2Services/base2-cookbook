#
# Cookbook Name:: base2
# Recipe:: metrics
#
# Copyright 2013, base2Services
#


## Install metrics required libraries

metrics_dependencies = ['bundler', 'rake', 'whenever']

metrics_dependencies.each do |gem_name|
  gem_package gem_name do
    gem_binary '/usr/bin/gem'
    options '--no-user-install'
    action :upgrade
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

# Setup cron
bash "install-metrics-cron" do
  code "bundle exec rake ciinabox:install_metrics_cron"
  environment ciinabox_metrics_env
  cwd "/opt/base2/ciinabox-metrics"
  user "ciinabox-metrics"
  action :run
end