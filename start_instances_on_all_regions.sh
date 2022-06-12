#!/bin/sh

for i in `./list_instances_on_all_regions.sh`
do
	aws ec2 --region `echo $i | cut -d : -f 1` start-instances --instance-ids `echo $i | cut -d : -f 3`
done
