#
# Cookbook Name:: base2
# Attribute:: default
#
# Copyright (C) 2014 base2Services
# 
# All rights reserved - Do Not Redistribute
#

default['base2']['nrpe']["servers"] = ["127.0.0.1"]

default['base2']['nrpe']['packages'] = case node['platform_family']
  when 'debian' #needs apt
    %w{ nagios-nrpe-server nagios-plugins nagios-plugins-basic nagios-plugins-standard }
  when 'rhel' #needs epel btw if !aws
    %w{ nagios-plugins-nrpe nagios-plugins-all nagios-nrpe openssl nrpe}
end

