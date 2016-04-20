#
# Cookbook Name::  base2
# Spec:: windows_users
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::windows_users' do
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

  it 'creates a windows user' do
    chef_run.node.set['base2']['windows']['users'] = [
      { username: 'username', password: 'N3wPassW0Rd', groups: ['Administrators']}
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_windows_home('username').with(
      password: 'N3wPassW0Rd'
    )
  end
end
