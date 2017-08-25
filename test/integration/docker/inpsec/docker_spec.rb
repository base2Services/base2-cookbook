require 'inspec'

describe package('libcgroup') do
  it { should be_installed }
end

describe service('docker') do
  it { should be_running }
end
