#!/bin/sh

# this script creates a instance on the region specified by a argument,
# lease a elastic IP, and assign the IP to the instance.

if [ $# -lt 3 ]; then
	echo 'usage: region-name friendly-name image-id'
	exit 1
fi

region=$1
option="--region $region --output json"

name=$2
name_prefix=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`
group=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`

image_id=$3

instance_type=`cat config.txt | grep '^instance_type' | cut -d '=' -f 2-`

# pre condition: public key, security group, and subnet must have been
# created before running this script
key_name=`cat config.txt | grep '^keypair_name' | cut -d '=' -f 2-`
sg_name="$name_prefix$name-sg"
subnet_name="$name_prefix$name-subnet"

echo get subnet id
subnetid=`aws ec2 $option describe-subnets | jq ".Subnets[] | select(.Tags[]?.Value == \"$subnet_name\") | .SubnetId" | sed 's/"//g'`
if [ -z $subnetid ]; then
	echo failed to get subnet id of $subnet_name
	exit 1
fi

echo get securiy group id
sgid=`aws ec2 $option describe-security-groups | jq ".SecurityGroups[] | select(.GroupName == \"$sg_name\") | .GroupId" | sed 's/"//g'`
if [ -z $sgid ]; then
	echo failed to get securiy group id of $sg_name
	exit 1
fi

echo run a instance
instance_id=`aws ec2 $option run-instances \
	--image-id $image_id \
	--instance-type $instance_type \
	--key-name $key_name \
	--security-group-ids $sgid \
	--tag-specifications "ResourceType=\"instance\",Tags=[{Key=Group,Value=$group}]" "ResourceType=\"volume\",Tags=[{Key=Group,Value=$group}]"\
	--subnet-id $subnetid \
	--count 1 | jq '.Instances[0].InstanceId' | sed 's/"//g'`

echo allocate elastic IP
alloc_id=`aws ec2 $option allocate-address --domain vpc | jq .AllocationId | sed 's/"//g'`

# wait until the instance gets ready
while [ `aws ec2 $option describe-instance-status --instance-ids $instance_id | jq '.InstanceStatuses[0].InstanceState.Name' | sed 's/"//g'` != running ]
do
	echo -n '.'
	sleep 1
done

echo assign elastic IP
aws ec2 $option associate-address --allocation-id $alloc_id --instance-id $instance_id

echo assign instance\'s name: ${name_prefix}replica
aws ec2 $option create-tags --resources $instance_id --tags "Key=Name,Value=${name_prefix}replica"

echo subnet-id: $subnetid
echo security-group-id: $sgid
echo instance-id: $instance_id
echo allocation-id: $alloc_id
