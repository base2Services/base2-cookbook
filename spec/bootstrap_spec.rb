#
# Cookbook Name::  base2
# Spec:: bootstrap
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::bootstrap' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'by default does not include any rutime recipes' do
    expect(chef_run).to write_log('Bootstrap role not set please ensure your instances are tagged correctly').with_level(:warn)
    expect_any_instance_of(Chef::Recipe).to_not receive(:include_recipe)
  end

  it 'should include a runtime cookbook base on the role attribute' do
    chef_run.node.set['base2']['role'] = 'base2::users'
    chef_run.converge(described_recipe)
    expect(chef_run).to write_log('Running Bootstrap for base2::users').with_level(:info)
    expect(chef_run).to include_recipe('base2::users')
  end

  it 'should raise an error when role does not have a matching recipe' do
    chef_run.node.set['base2']['role'] = 'base2::unknown'
    expect {
      chef_run.converge(described_recipe)
    }.to raise_error(Chef::Exceptions::RecipeNotFound)
  end

end
