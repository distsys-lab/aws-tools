#!/bin/sh

if [ $# -lt 2 ]; then
	echo 'usage: region-name friendly-name'
	exit 1
fi

region=$1
location=$2
option="--region $region --output json"
name_prefix=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`

sg_name="$name_prefix-bft-$location-sg"
sgid=`aws ec2 $option describe-security-groups | jq ".SecurityGroups[] | select(.GroupName == \"$sg_name\") | .GroupId" | sed 's/"//g'`
if [ -z $sgid ]; then
	echo failed to get securiy group id of $sg_name
	exit 1
fi

echo $sgid
aws ec2 $option  authorize-security-group-ingress --group-id $sgid --protocol icmp --port -1 --cidr 0.0.0.0/0

