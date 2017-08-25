require 'inspec'

describe service('awsagent') do
  it { should be_running }
end
