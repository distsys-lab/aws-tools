#!/bin/sh

regions=`cat config.txt | grep '^region_list' | cut -d '=' -f 4-`

build_date=`date +%Y-`
search_words_prefix="Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on "
owner_id=099720109477

read_timeout=0
connect_timeout=0
timeout_option="--cli-read-timeout $read_timeout --cli-connect-timeout $connect_timeout"

for r in `cat $regions | cut -d : -f 1`
do
	id_and_description=`aws $timeout_option ec2 --region $r describe-images --filters "Name=description,Values=\"$search_words_prefix$build_date*\"" "Name=virtualization-type,Values=hvm" "Name=state,Values=available" "Name=owner-id,Values=$owner_id" "Name=block-device-mapping.volume-type,Values=gp2" \
		| jq '.Images | sort_by(.CreationDate) | .[-1].ImageId,.[-1].Description' | sed 's/"//g' | xargs | sed 's/ /:/'`
	echo $r:$id_and_description
done
