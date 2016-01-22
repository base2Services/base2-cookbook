#
# Cookbook Name:: base2
# Recipe:: codedeploy
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

remote_file "/usr/src/code_deploy_install" do
  source "https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install"
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
