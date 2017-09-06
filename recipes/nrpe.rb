node['base2']['nrpe']['packages'].each do | p |
  package p
end

#note:
#default for allowed_hosts = ['127.0.0.1']

#note:
#To include more build on this before you call this Recipe
#or use node['base2']['nrpe']['monitoring_servers']
#e.g
#On the server...
# if node.run_list.roles.include?(node['base2_monitoring']['server_role'])
#  node.default['base2']['nrpe']['monitoring_servers']  << node['ipaddress']
#On a node...
#  node.default['base2']['nrpe']['monitoring_servers'] << node['local_cookbook']['nrpe']['array_of_monitoring_servers']

#handy place to put your incinga2/nagios servers etc
allowed_hosts.concat node['base2']['nrpe']['monitoring_servers']  if node['base2']['nrpe']['monitoring_servers']

directory node['base2']['nrpe']['include_dir'] do
  owner node['base2']['nrpe']['user']
  group node['base2']['nrpe']['group']
  mode 00755
end

template "#{node['base2']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe/nrpe.cfg.erb"
  owner node['base2']['user']
  group node['base2']['group']
  mode 00644
  notifies :restart, "service[#{node['base2']['nrpe']['service_name']}]"
end

execute 'touch_sysconfig_network' do
  command 'touch /etc/sysconfig/network'
  action :run
end

service node['base2']['nrpe']['service_name'] do
  action [:enable]
  supports :restart => true, :status => false
end
