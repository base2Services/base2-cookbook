#
# Cookbook Name:: base2
# Recipe:: docker
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

package 'libcgroup' do
 action :install
end

docker_installation_script 'default'

docker_installation_binary 'default' do
  version node['base2']['docker_version']
  checksum node['base2']['docker_checksum'] if node['base2']['docker_checksum'] 
  action :create
  only_if node['base2']['docker_version']
end

service 'docker' do
  action [:enable, :start]
end

directory "/tmp/containers" do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

node['base2']['docker']['images'].each do |image|

  execute 'download_docker_images_from_s3' do
    command "aws --region #{image['region']} s3 cp s3://#{image['bucket']}/containers/#{image['repo']}/#{image['name']}/#{image['tag']}/#{image['name']}.tar /tmp/containers/#{image['name']}-#{image['tag']}.tar"
    action :run
  end

  execute 'load container' do
    command "docker load -i /tmp/containers/#{image['name']}-#{image['tag']}.tar"
    action :run
  end

  execute 'clean up container' do
    command "rm -f /tmp/containers/#{image['name']}-#{image['tag']}.tar"
    action :run
  end

end

execute 'docker_list_images' do
  command 'docker images'
  action :run
end
