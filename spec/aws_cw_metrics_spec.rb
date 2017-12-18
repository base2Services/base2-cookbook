#
# Cookbook Name::  base2
# Spec:: aws_cw_metrics
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::aws_cw_metrics' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("false").and_return(false)
  end

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'should install os packages' do
    chef_run.node.normal['platform_family'] = 'rhel'
    chef_run.converge(described_recipe) # The converge happens inside the test
    expect(chef_run).to install_package('rubygem-io-console')
  end

  it 'should install ruby gems' do
    expect(chef_run).to install_gem_package('bundler')
    expect(chef_run).to install_gem_package('rake')
    expect(chef_run).to install_gem_package('whenever')
  end

  it 'should create ciinabox metrics user' do
    expect(chef_run).to create_user('ciinabox-metrics')
  end

  it 'should create profile.d PATH altering scripts' do
    expect(chef_run).to create_cookbook_file('/etc/profile.d/env_path.sh')
  end

  it 'should create the metrics directoris' do
    expect(chef_run).to create_remote_directory('/opt/base2/ciinabox-metrics')
    expect(chef_run).to create_remote_directory('/etc/ciinabox-metrics')
  end

end
