#
# Cookbook Name:: base2
# Attribute:: files
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

default['base2']['permissions']['directory']['/opt/base2/bin']['user'] = 'root'
default['base2']['permissions']['directory']['/opt/base2/bin']['group'] = 'root'
default['base2']['permissions']['directory']['/opt/base2/bin']['mode'] = '755'

default['base2']['permissions']['directory']['/opt/base2/ciinabox-metrics']['user'] = 'ciinabox-metrics'
default['base2']['permissions']['directory']['/opt/base2/ciinabox-metrics']['group'] = 'ciinabox-metrics'
default['base2']['permissions']['directory']['/opt/base2/ciinabox-metrics']['mode'] = '755'

default['base2']['permissions']['directory']['/etc/ciinabox-metrics']['user'] = 'ciinabox-metrics'
default['base2']['permissions']['directory']['/etc/ciinabox-metrics']['group'] = 'ciinabox-metrics'
default['base2']['permissions']['directory']['/etc/ciinabox-metrics']['mode'] = '755'