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

  it 'should create the base2 ec2-bootstrap script' do
    expect(chef_run).to create_cookbook_file('/opt/base2/bin/ec2-bootstrap')
  end

  it 'should create the base2 find_asg_ip script' do
    expect(chef_run).to create_cookbook_file('/opt/base2/bin/find_asg_ip')
  end

  it 'should create the base2 wait_for_alb script' do
    expect(chef_run).to create_cookbook_file('/opt/base2/bin/wait_for_alb')
  end

  it 'should create the base2 wait_for_elb script' do
    expect(chef_run).to create_cookbook_file('/opt/base2/bin/wait_for_elb')
  end

  it 'should create the base2 get_ssm_parameters script' do
    expect(chef_run).to create_cookbook_file('/opt/base2/bin/get_ssm_parameters')
  end

  it 'should create the base2 attach_ebs script' do
    expect(chef_run).to create_cookbook_file('/opt/base2/bin/attach_ebs')
  end

  it 'should create the base2 attach_eni script' do
    expect(chef_run).to create_cookbook_file('/opt/base2/bin/attach_eni')
  end

end
