require 'inspec'


describe user('base2') do
   it { should exist }
   its('home') { should eq '/home/base2' }
   its('shell') { should eq '/bin/bash' }
end

describe file('/home/base2/.ssh/authorized_keys') do
  it { should exist }
  it { should be_file }
  its('mode') { should cmp '0600' }
end

describe file('etc/sudoers.d/base2') do
  it { should exist }
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0600' }
  its('content') { should match /base2 ALL = NOPASSWD: ALL/ }
end
