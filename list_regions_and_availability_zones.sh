#!/bin/sh

for i in `aws ec2 describe-regions | jq -r '.Regions[].RegionName'`
do
	for j in `aws --region $i ec2 describe-availability-zones | jq -r '.AvailabilityZones[].ZoneName'`
	do
		echo $i:$j
	done
done
