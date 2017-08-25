require 'inspec'

['telnet', 'mc', 'screen', 'sysstat','traceroute'].each do |pkg|

  describe package(pkg) do
    it { should be_installed }
  end

end

describe gem('aws-sdk') do
  it { should be_installed }
  its('version') { should eq '2.9.44' }
end

describe command('aws') do
  it { should exist }
end
