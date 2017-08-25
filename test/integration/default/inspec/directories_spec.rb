require 'inspec'

["archive", "backups", "config", "bin", "scripts"].each do |dir|

  describe directory("/opt/base2/#{dir}") do
    it { should exist }
  end

end

['ec2-bootstrap', 'ec2-bootstrap.py', 'find_asg_ip', 'wait_for_alb', 'wait_for_elb', 'get_ssm_parameters'].each do | file |

  describe file("/opt/base2/bin/#{file}") do
    it { should exist }
    it { should be_file }
  end

end
