# base2 cookbook

# Requirements

# Usage

Add the base2 cookbook to your berksfile and include the default recipe

include_recipe "base2::default"

# Attributes

default['system']['timezone']   - Country/City, as per /usr/share/zoneinfo
default['common']['packages']   - Default packages to install.

# Recipes

# Files

## ec2-bootstrap
**Suported OS:** Linux

##### Purpose
Auto discovery of EC2 Tags to generate chef override.json and triggers chef

##### Usage
Add into userdata
```
/opt/base2/bin/ec2-bootstrap <AWS::Region> <AWS::AccountId>
```

## EC2-Bootstrap.ps1
**Suported OS:** Windows

##### Purpose
Auto discovery of EC2 Tags to generate chef override.json and triggers chef

##### Usage
Call from userdata in cloudformation
```
C:/base2/bin/EC2-Bootstrap.ps1
```

## find_asg_ip
**Suported OS:** Linux

##### Purpose
Auto discovery of all EC2 instances based of the Environment tag and displays to the user Name, IP address and InstanceId

##### Usage
manually execute the file on the host or build in to your motd to see it when you log on.

## get_ssm_parameters
**Suported OS:** Linux, Windows

##### Purpose
Retrieve encrypted secrets in AWS SSM Parameter store and add into chef override.json

##### Usage
Requires a tag `SSMParameters` set to `true` on the EC2 instance for the bootstrap to run the script.<br />
Create your SSM parameters using your favourite method
The SSM Parameter naming convention is as follows `default..base2..app..SECRET`<br />

* Delimiter
  * `..` Separates each section of the Name
* Environment or Global Identifier (First section of name)
  * `default` is a global identifier allowing this secret to be used across all environments for a given AWS account  
  * `environment` is a environment specific Parameter that will only be retrieved for that environment. This will override any globally set parameters
* Chef attribute
  * The identifier gets stripped off the name which then turns the rest of the name into a chef attribute i.e. `node['base2']['app']['SECRET']`
  * This attribute is store in the override.json file and can be called in a recipe as you normally would.

Examples:
* The parameter name `default..base2..app..SECRET` becomes the chef attribute `node['base2']['app']['SECRET']` in the chef recipe and is available in **all** environments
* The parameter name `dev..base2..app..APIKEY` becomes the chef attribute `node['base2']['app']['APIKEY']` in the chef recipe and is available in just the **dev** environment
* The parameter name `prod..base2..app..SECRET` becomes the chef attribute `node['base2']['app']['SECRET']` in the chef recipe and is available in just the **prod** environment and overrides the `default..base2..app..SECRET` parameter

## wait_for_alb
**Suported OS:** Linux, Windows

##### Purpose
Waits for a EC2 instance to become healthy in specified target group(s)

##### Usage
Call from userdata in cloudformation after chef run.
```
/opt/base2/bin/wait_for_alb -r <AWS::Region> -i <InstanceId> -t <TargetGroupA>,<TargetGroupB> -T 2000
```

#### Options
`-r` `--region` - specify a aws region i.e. -r ap-southeast-2 <br />
`-t` `--target-groups` - specify one or more target group arns seperated by comma i.e. -t arn::1,arn::2<br />
`-i` `--instance-id` - specify the ec2 instance id i.e. -i i-0a5c9e3f2ff024ce9<br />
`-T` `--timeout` - Time out in seconds, defaults to 3600

## wait_for_elb
**Suported OS:** Linux, Windows

##### Purpose
Queries all elastic load balancers in the region that contain the instance-id
Waits for the ec2 instance to become healthy in the classic elastic load balancer(s)

##### Usage
Call from userdata in cloudformation after chef run.
```
/opt/base2/bin/wait_for_elb -r <AWS::Region> -i <InstanceId> -T 2000
```

#### Options
`-r` `--region` - specify a aws region i.e. -r ap-southeast-2 <br />
`-i` `--instance-id` - specify the ec2 instance id i.e. -i i-0a5c9e3f2ff024ce9<br />
`-T` `--timeout` - Time out in seconds, defaults to 3600

## Stripe-Windows-Ephemeral-Disks.ps1
**Suported OS:** Windows

##### Purpose
To create a stripped ephemeral disk on compatible windows EC2 instances

##### Usage
Call from userdata in cloudformation
```
C:/base2/bin/Stripe-Windows-Ephemeral-Disks.ps1
```

## attach_eni
**Suported OS:** Linux, Windows (untested)

##### Purpose
Attaches an Elastic Network Interface to an EC2 instance based on a tag or ID.

##### Usage
Call from userdata in cloudformation.
```
/opt/base2/bin/attach_eni -r <AWS::Region> -n <ElasticNetworkInterfaceID>
```

#### Options
`-r` `--region` - specify a aws region i.e. -r ap-southeast-2 <br />
`-t` `--tag` - specify eni reservation tag [Required if -n or --network-interface not specified]<br />
`-n` `--network-interface` - specify eni id [Required if -t or --tag not specified]<br />
`-d` `--device-index` - specify device index for eni, defaults to 1 [Optional]<br />
`-T` `--timeout` - specify timeout for script, defaults to 600 [Optional]

# Author

Author:: itsupport@base2services.com
