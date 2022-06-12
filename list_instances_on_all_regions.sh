#!/bin/sh

regions=`cat config.txt | grep '^region_list' | cut -d '=' -f 2-`

group_name=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`
filter="--filters Name=\"tag:Group\",Values=\"$group_name\""
if [ $# -ge 1 -a x$1 = xany ]; then
	filter=
fi

for r in `cat $regions | cut -d : -f 1`
do
	city=`cat $regions | grep $r | cut -d : -f 3`
	instance=`aws --region $r ec2 describe-instances $filter | \
		jq ".Reservations[].Instances[].InstanceId,.Reservations[].Instances[].PublicIpAddress,.Reservations[].Instances[].State.Name" | \
		sed 's/"//g' | xargs | sed 's/ /:/g'`
	echo $r:$city:$instance
done
