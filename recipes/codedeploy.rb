#
# Cookbook Name:: base2
# Recipe:: codedeploy
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#
case node['platform_family']
when 'windows'
  windows_package 'aws_code_deploy' do
    source "https://aws-codedeploy-#{node['base2']['codedeploy_region']}.s3.amazonaws.com/latest/codedeploy-agent.msi"
    action :install
  end
else
  remote_file "/usr/src/code_deploy_install" do
    source "https://aws-codedeploy-#{node['base2']['codedeploy_region']}.s3.amazonaws.com/latest/install"
    mode 0744
    notifies :run, "execute[install_code_deploy]", :immediately
  end

  execute "install_code_deploy" do
    action :nothing
    command "/usr/src/code_deploy_install auto"
  end

  service "codedeploy-agent" do
    action [:start, :enable]
  end

  #install ssm-agent
  remote_file '/usr/src/amazon-ssm-agent.rpm' do
    source "https://amazon-ssm-#{node['base2']['codedeploy_region']}.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm"
    owner 'root'
    group 'root'
    notifies :run, "execute[install_ssm_agent]", :immediately
    only_if node['base2']['ssm_agent']
  end

  execute 'install_ssm_agent' do
    command 'yum install -y /usr/src/amazon-ssm-agent.rpm'
    action :nothing
    only_if node['base2']['ssm_agent']
  end
end
