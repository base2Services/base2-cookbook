#
# Cookbook Name:: base2
# Recipe:: windows_security
#
# Copyright (C) 2014 base2Services
#
# All rights reserved - Do Not Redistribute
#

#Disable SMB 1.0/CIFS File Sharing Support for security purposes
windows_feature 'FS-SMB1' do
  action :remove
   provider :windows_feature_powershell
 end
