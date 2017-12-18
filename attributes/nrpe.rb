#
# Cookbook Name:: base2
# Attribute:: default
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

#use this downstream to add servers
default['base2']['nrpe']['allowed_hosts'] = ['127.0.0.1']


default['base2']['nrpe']['packages'] = case node['platform_family']
  when 'debian' #needs apt
    %w{ nagios-nrpe-server nagios-plugins nagios-plugins-basic nagios-plugins-standard }
  when 'rhel' #needs epel btw if !aws
    %w{ nagios-plugins-nrpe nagios-plugins-all nagios-nrpe openssl nrpe}
  when 'amazon'
    %w{ nagios-plugins-nrpe nagios-plugins-all nagios-nrpe openssl nrpe }
  else
    %w{ }
end

#common in nrpe.cfg across all os
default['base2']['nrpe']['conf_dir'] = '/etc/nagios'
default['base2']['nrpe']['dont_blame_nrpe'] = 0
default['base2']['nrpe']['allow_bash_command_substitution']=0
default['base2']['nrpe']['debug']=0
default['base2']['nrpe']['command_timeout'] = 60
default['base2']['nrpe']['connection_timeout']=300

#defaults that may change depending on os
default['base2']['nrpe']['pid'] = '/var/run/nagios/nrpe.pid'
default['base2']['nrpe']['user'] = 'nagios'
default['base2']['nrpe']['group'] = 'nagios'
default['base2']['nrpe']['plugin_dir'] = '/usr/lib/nagios/plugins'
default['base2']['nrpe']['include_dir'] = '/etc/nagios/nrpe.d/'
default['base2']['nrpe']['include_nrpe_local'] = false
default['base2']['nrpe']['service_name'] = 'nrpe'

case node['platform_family']
when 'rhel','fedora'
  default['base2']['nrpe']['user'] = 'nrpe'
  default['base2']['nrpe']['group'] = 'nrpe'
  default['base2']['nrpe']['include_dir'] = '/etc/nrpe.d/'
  default['base2']['nrpe']['pid'] = '/var/run/nrpe/nrpe.pid'
  if node['kernel']['machine'] != "i686"
    default['base2']['nrpe']['plugin_dir'] = '/usr/lib64/nagios/plugins'
  end
when 'debian'
  default['base2']['nrpe']['include_nrpe_local'] = true
  default['base2']['nrpe']['service_name'] = 'nagios-nrpe-server'
end

#common in nrpe.cfg
default['base2']['nrpe']['conf_dir'] = '/etc/nagios'
default['base2']['nrpe']['dont_blame_nrpe'] = 0
default['base2']['nrpe']['allow_bash_command_substitution']=0
default['base2']['nrpe']['debug']=0
default['base2']['nrpe']['command_timeout'] = 60
default['base2']['nrpe']['connection_timeout']=300
