require 'aws-sdk'

# Helper function that actually calls the AWS API
def put_metrics(cw_client, dimensions, metric_configuration, value)
  put_metric_params = Aws::CloudWatch::Types::PutMetricDataInput.new(
      {
          'namespace' => metric_configuration['namespace'],
          'metric_data' => [Aws::CloudWatch::Types::MetricDatum.new(
              {
                  'value' => value,
                  'dimensions' => dimensions,
                  'metric_name' => metric_configuration['name']
              })]
      })
  put_metric_params['metric_data'][0]['unit'] = metric_configuration['unit'] if metric_configuration['unit'] != nil
  cw_client.put_metric_data(put_metric_params)
end



def write_instance_info(json_file_path)

  # Read instance info
  region = `curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\\" '{print $4}'|xargs echo -n`
  az = `curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
  instance_id = `curl -s http://instance-data/latest/meta-data/instance-id`

  Aws.config.update({region: region})
  ec2client = Aws::EC2::Client::new()

  # Read tags
  tags = ec2client.describe_tags(
      {filters: [{name: 'resource-id', values: [instance_id]}]}
  ).tags.map { |t| [t['key'],t['value']] }

  tags = Hash[*tags.flatten(1)]

  # Write to file
  cache_obj = {
      'tags' => tags,
      'region' => region,
      'az' => az,
      'instance_id' => instance_id
  }

  File.open(json_file_path,'w') do |f|
    f.write(cache_obj.to_json)
  end

end


# Main method - processes single metric configuration object
def process_metric(metric_configuration, instance_info)

  region = instance_info['region']
  az = instance_info['az']
  instance_id = instance_info['instance_id']
  tags = instance_info['tags']

  cw_client = Aws::CloudWatch::Client.new({region: region})
  ec2client = Aws::EC2::Client::new({region: region})


  if metric_configuration == nil
    STDERR.puts "Configuration #{configuration_name} not found or not specified"
    exit -1
  end

  metrics_script = metric_configuration['script']

  if metrics_script == nil
    STDERR.puts "Script not defined for configuration #{configuration_name}"
    exit -1
  end

  scripts_root = ENV['CIINABOX_METRICS_SCRIPTS'] || 'scripts'

  if scripts_root == nil
    STDERR.puts "Scripts directory not defined."
    exit -1
  end

  metrics_script_path = "#{scripts_root}/#{metrics_script}"

  metrics_value=`#{metrics_script_path}`
  script_rval=$?.exitstatus
  if script_rval != 0
    STDERR.puts "Script #{metrics_script_path} exited with non-zero value #{script_rval}"
    exit -1
  end


  instance_name = tags['Name']

  if instance_name == nil
    instance_name = '(no name)'
  end
  metrics_value.each_line do |metric_line|
    metric_def = metric_line.split(':')
    default_dimension_val = nil
    default_dimension = []
    if metric_def.length == 3
      default_dimension_val = metric_def[0]
      value = metric_def[1]
      custom_dimensions = metric_def[2]
    end

    if metric_def.length == 2
      value = metric_def[0]
      custom_dimensions = metric_def[1]
    end

    # Pick up default dimension, if one specified
    if default_dimension_val
      default_dimension << {name: metric_configuration['default_dimension'], value: default_dimension_val}
    end

    # Metrics per AZ
    if metric_configuration['dimensions']['availability_zone']
      dimensions = [{name: 'Per-AZ', value: az}]
      put_metrics(cw_client, dimensions.concat(default_dimension), metric_configuration, value)
    end

    # Metrics per Instance
    if metric_configuration['dimensions']['instance']
      dimensions = [{name: 'Per-Instance', value: instance_id}, {name: 'Instance-Name', value: instance_name}]
      put_metrics(cw_client, dimensions.concat(default_dimension), metric_configuration, value)
    end

    # Metrics per ASG
    if metric_configuration['dimensions']['asg']
      dimension_value = tags['aws:autoscaling:groupName']
      if metrics_value != nil
        dimensions = [{name: 'Per-ASG', value: dimension_value}]
        put_metrics(cw_client, dimensions.concat(default_dimension), metric_configuration, value)
      end

    end

    # Metrics per Specific Tag
    if metric_configuration['dimensions']['tags']
      metric_configuration['dimensions']['tags'].each do |tag|
        tag_value = tags[tag]
        if tag_value != nil
          dimensions = [{name: "Per-#{tag}", value: tag_value}]
          put_metrics(cw_client, dimensions.concat(default_dimension), metric_configuration, value)
        end
      end
    end

    # Custom dimensions produced by script output
    if not custom_dimensions.empty? and custom_dimensions != ""
      dimensions = custom_dimensions.scan(/(.*?)=(.*?)\s/).map { |x| {name: x[0], value: x[1]} }
      if (dimensions.length > 0)
        put_metrics(cw_client, dimensions.concat(default_dimension), metric_configuration, value)
      end
    end


  end
end


