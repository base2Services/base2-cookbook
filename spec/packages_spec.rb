#
# Cookbook Name::  base2
# Spec:: packages
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::packages' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("false").and_return(false)
  end

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

end
