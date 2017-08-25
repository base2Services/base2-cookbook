require 'inspec'

%w{ nagios-plugins-nrpe nagios-plugins-all openssl nrpe}.each do |pkg|

  describe package(pkg) do
    it { should be_installed }
  end

end

describe file ('/etc/nagios/nrpe.cfg') do
  it { should exist }
  its('content') { should match /allowed_hosts=127\.0\.0\.1/ }
end

describe service('nrpe') do
  it { should be_enabled }
  it { should_not be_running }
end
