#!/bin/sh

IFS=$'
'

regions=`cat config.txt | grep '^region_list' | cut -d '=' -f 2-`

for i in `cat $regions`
do
	region=`echo $i | cut -d : -f 1`
	name=`echo $i | cut -d : -f 3`

	echo ./create_my_vpc.sh $region $name
	./create_my_vpc.sh $region $name
done
