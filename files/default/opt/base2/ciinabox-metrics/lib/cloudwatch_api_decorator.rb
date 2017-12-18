
class CloudWatchApiDecorator

  @cw_client = nil
  @max_data_points_in_batch

  # Batched metrics is map of namespaces to list of batches of metrics
  @batched_metrics

  attr_accessor :cw_client
  attr_accessor :max_data_points_in_batch


  def initialize()
    @batched_metrics = {}
  end

  def add_metric(dimensions, metric_configuration, value)
    # Handle namespace creation
    namespace = metric_configuration['namespace']
    if (@batched_metrics[namespace] == nil)
      @batched_metrics[namespace] = []
    end
    namespace_batch_list = @batched_metrics[namespace]

    last_metric_data_input = @batched_metrics[namespace].last()
    # If there are no batches created yet, or last batch is filled up
    if (last_metric_data_input == nil or last_metric_data_input.metric_data.size() >= $cloudwatch_metrics_batch_limit)
      @batched_metrics[namespace] << Aws::CloudWatch::Types::PutMetricDataInput.new(
          {
              'namespace' => metric_configuration['namespace'],
              'metric_data' => []
          })
      last_metric_data_input = @batched_metrics[namespace].last()
    end

    # Add metric to batch
    last_metric_data_input.metric_data << Aws::CloudWatch::Types::MetricDatum.new(
        {
            'value' => value,
            'dimensions' => dimensions,
            'metric_name' => metric_configuration['name']
        })

    # If configuration defines unit add it to metric
    if metric_configuration['unit'] != nil
      last_metric_data_input.metric_data.last()['unit'] = metric_configuration['unit']
    end

  end

  def flush_metrics_to_cw()
    @batched_metrics.each { |namespace,metric_data_input_array|
      puts "Sending metrics to CW for namespace #{namespace}"
      puts "Number of batches: #{metric_data_input_array.size()}"

      batch_no = 1
      metric_data_input_array.each { |metric_data_input|
        puts "Sending #{metric_data_input.metric_data.size()} data points in batch \##{batch_no}"
        @cw_client.put_metric_data(metric_data_input)
        batch_no = batch_no + 1
      }
    }
  end

end