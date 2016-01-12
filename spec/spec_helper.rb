# spec_helper.rb

require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks (default: [inferred from
  # the location of the calling spec file])
  config.cookbook_path = '../'

  # Specify the Chef log_level (default: :warn)
  config.log_level = :error

end
