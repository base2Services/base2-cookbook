#
# Cookbook Name::  base2
# Spec:: docker
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

RSpec.configure do |config|
  config.platform = 'amazon'
  config.version  = '2014.09'
end

describe 'base2::docker' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("aws").and_return(true)
  end

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

end
