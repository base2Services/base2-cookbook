#!/usr/bin/python
import boto.utils
import boto.ec2
import sys
import os

application_name = "base2"
if len(sys.argv) > 1:
  application_name = sys.argv[1]

instance_id = boto.utils.get_instance_metadata()['instance-id']
document = boto.utils.get_instance_identity()['document']
region = document['region']
account_id = document['accountId']
az_char = document['availabilityZone'][-1:]

replacements = {'region': region,
               'data_volume_id': None,
               'instance_id': instance_id,
               'account_id': account_id,
                'az_char': az_char,
                'application_name': application_name}

#connect to ec2 service and get all the tags
conn=boto.ec2.connect_to_region(region)
instance = conn.get_only_instances(instance_ids=instance_id)[0]
for tag, value in instance.tags.iteritems():
  #ignore the aws tags - e.g. CF tags
  if not tag.startswith('aws:'):
    ec2_tag = "ec2_" + tag
    replacements[ec2_tag.lower()] = value

app_build_no = None
app_build_sha = None

#env_file will have settings in python format
#for build_no etc
env_file = '/opt/' + application_name +'/' + application_name +'_env.py'
try:
  execfile(env_file)
except:
  print "#error on exec for " + env_file

replacements['app_build_no'] = app_build_no
replacements['app_build_sha'] = app_build_sha

print replacements

print """
export AWS_REGION={region}
export DATA_VOLUME_ID={data_volume_id}
export INSTANCE_ID={instance_id}
export AWS_ACCOUNT_ID={account_id}
""".format(**replacements)

#we do the cat on the cmd line
#as chef did not like the json we wrote
chef_json = """
cat <<EOT > /etc/chef/override.json
{{
  "{application_name}": {{
    "aws_account_id":"{account_id}",
    "role": "{ec2_role}",
    "region": "{region}",
    "az": "{az_char}",
    "build_no": "{app_build_no}",
    "build_sha": "{app_build_sha}",
    "environment": {{
      "type": "{ec2_environment}"
    }},
    "ec2": {{
      "instance-id": "{instance_id}"
    }}
  }}
}}
EOT
""".format(**replacements)

os.system(chef_json)

print "#Executing bootstrap for {ec2_role} for environment {ec2_environment}".format(**replacements)

chef_cmd = """cd /etc/chef &&
/opt/chef/bin/chef-client --local-mode -E {ec2_environment} -j /etc/chef/override.json -o 'recipe[runtime::default]'""".format(**replacements)

os.system(chef_cmd)
