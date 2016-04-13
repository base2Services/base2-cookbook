#
# Cookbook Name::  base2
# Spec:: default
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::default' do

  before do
    stub_command("true").and_return(true)
    stub_command("curl -s http://instance-data.ec2.internal").and_return(true)
    stub_command("which pip").and_return(true)
  end

  describe 'On windows platform' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'windows',
        version: '2012R2'
      )
      runner.converge(described_recipe)
    end

    it 'does not raise an exception' do
      expect { chef_run }.to_not raise_error
    end

    it 'should include the windows but not include directories recipe' do
      expect(chef_run).to include_recipe('base2::windows')
      expect(chef_run).to_not include_recipe('base2::directories')
    end
  end

  describe 'On non-windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'does not raise an exception' do
      expect { chef_run }.to_not raise_error
    end

    it 'should include the directories but not include windows recipe' do
      expect(chef_run).to_not include_recipe('base2::windows')
      expect(chef_run).to include_recipe('base2::directories')
    end
  end
end
