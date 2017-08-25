require 'inspec'

describe file('/etc/localtime') do
  it { should exist }
  it { should be_symlink }
  it { should_not be_directory }
  its('link_path') { should eq '/usr/share/zoneinfo/Australia/Melbourne' }
end
