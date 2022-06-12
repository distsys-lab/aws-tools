#!/bin/bash

#set -x

IFS='
'

regions=`cat config.txt | grep '^region_list' | cut -d '=' -f 2-`

for i in `cat $regions`
do
	region=`echo $i | cut -d : -f 1`
	name=`echo $i | cut -d : -f 3`

	echo $name
	aws --region $region ec2 describe-addresses | jq -r ".Addresses[].PublicIp"
done
