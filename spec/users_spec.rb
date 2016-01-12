#
# Cookbook Name::  base2
# Spec:: docker
#
# Copyright (C) 2015 base2Services
#
# All rights reserved - Do Not Redistribute
#
require_relative 'spec_helper'

describe 'base2::users' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'does not raise an exception' do
    expect { chef_run }.to_not raise_error
  end

  it 'creates the base2 user' do
    expect(chef_run).to create_user('base2')
  end

  it 'creates the base2 user home directory' do
    expect(chef_run).to create_directory('/home/base2/.ssh')
      .with_user('base2')
  end

  it 'creates the base2 users authorized_keys file' do
    expect(chef_run).to create_file('/home/base2/.ssh/authorized_keys')
      .with_content(/\#generated and managed by chef/)
  end

  it 'creates the base2 users sudoers file' do
    expect(chef_run).to create_file('/etc/sudoers.d/base2')
      .with_content(/base2 ALL = NOPASSWD: ALL/)
  end

  it 'creates a custom user when add an custom node' do
    chef_run.node.set['base2']['users']['custom'] = [
      'ssh-rsa AAAAB3N'
    ]
    chef_run.converge(described_recipe)
    expect(chef_run).to create_user('base2')
    expect(chef_run).to create_user('custom')
  end

end
