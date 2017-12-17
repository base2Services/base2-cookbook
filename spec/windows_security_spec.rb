#
# Cookbook Name::  base2
# Spec:: windows_security
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::windows_security' do
  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'windows',
      version: '2012R2'
    )
    runner.converge(described_recipe)
  end

  before do
    stub_command("false").and_return(false)
  end

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'removes SMB windows feature' do
    expect(chef_run).to remove_windows_feature('FS-SMB1')
  end

end
