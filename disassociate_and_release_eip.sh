#!/bin/sh

if [ $# -lt 2 ]; then
	echo 'usage: region-name instance-id'
	exit 1
fi

region=$1
option="--region $region --output json"

iid=$2

# retrieve association id
assoc_id=`aws $option ec2 describe-addresses --filters "Name=instance-id,Values=$iid" | jq ".Addresses[].AssociationId" | sed 's/"//g'`
# retrieve allocation id
alloc_id=`aws $option ec2 describe-addresses --filters "Name=instance-id,Values=$iid" | jq ".Addresses[].AllocationId" | sed 's/"//g'`

# disassociate address
aws $option ec2 disassociate-address --association-id $assoc_id
# release address
aws $option ec2 release-address --allocation-id $alloc_id

echo $region $iid
echo $assoc_id
echo $alloc_id

