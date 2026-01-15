#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0c6ddf05e0664965e"
INSTANCES=("mongodb" "redis" "mysql" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z03171147RXIT58UUGL6"
DOMAIN_NAME="rachelsigao.online"

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$( aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-0c6ddf05e0664965e --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then 
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
    else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
    fi
    echo "$instance IP address: $IP"
done
