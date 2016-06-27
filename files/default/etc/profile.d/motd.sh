#!/bin/sh
AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s)
REGION=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s|rev|cut -c 2-|rev)
INSTANCEID=$(curl http://169.254.169.254/latest/meta-data/instance-id -s)
INFO=($(aws --region $REGION ec2 describe-instances --filters "Name=instance-id,Values=$INSTANCEID" --query "Reservations[].Instances[0].[LaunchTime,ImageId,Tags[?ends_with(Key,'Environment')].Value,Tags[?starts_with(Key,'Role')].Value]" --output text))
INSTANCES=($(aws --region $REGION ec2 describe-instances --filters "Name=tag:Environment,Values=${INFO[2]}" --query "Reservations[].Instances[].[Tags[?starts_with(Key,'Name')].Value,InstanceId,PrivateIpAddress]" --output text))

printf "=================================================================\n"
printf "| %-20s | %-15s | %-20s\n" INSTANCE\ ID PRIVATE\ IP NAME
printf "=================================================================\n"
printf "| %-20s | %-15s | %-20s\n-----------------------------------------------------------------\n" ${INSTANCES[@]}
