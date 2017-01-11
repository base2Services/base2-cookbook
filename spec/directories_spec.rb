#
# Cookbook Name::  base2
# Spec:: directories
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::directories' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'should create the base2 bin directory' do
    expect(chef_run).to create_directory('/opt/base2/bin')
  end

  it 'should create the base2 bin directory with files' do
    expect(chef_run).to create_remote_directory('/opt/base2/bin')
  end

  it 'should create the base2 ciinabox metrics directory' do
    expect(chef_run).to create_remote_directory('/opt/base2/ciinabox-metrics')
    expect(chef_run).to create_remote_directory('/etc/ciinabox-metrics')
  end

end
