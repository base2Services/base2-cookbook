#warning this is opinionated
service node['base2']['nrpe']['service_name'] do
  action :nothing
end

node['base2']['nrpe']['include_dir']
node["base2"]['nrpe']['nrep_checks'].each do | check |
  name, options = check.first
  command = "command[#{name}]=#{node['base2']['nrpe']['include_dir']}#{script_name}"
  script_name = name unless options["script_name"]
  options.each do | c, o |
    command = "#{command} -#{c} #{o}" unless c = "script_name" or c = "extra_options"
  end
  command = "#{command} #{extra_options}"
  log command
end  

