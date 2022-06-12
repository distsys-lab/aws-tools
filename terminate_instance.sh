#!/bin/sh

if [ $# -lt 2 ]; then
	echo 'usage: region-name instance-id'
	exit 1
fi

region=$1
option="--region $region --output json"

iid=$2

#aws $option ec2 --dry-run terminate-instances --instance-ids $iid
aws $option ec2 terminate-instances --instance-ids $iid
