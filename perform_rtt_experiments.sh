#!/bin/bash

#set -x

# use UTC throughout the experiment
export TZ=UTC

# results will be stored here
base_dir=~/Desktop/aws-tools/data/aws-inter-region-rtt

ssh_option="-i ~/.ssh/id_rsa"

#regions=(ohio virginia california oregon mumbai seoul singapore sydney tokyo canada frankfurt ireland london saopaulo)
regions=(ohio virginia)
region_prefix=bft-

user=ubuntu

server_command=ping
server_option="-c 10"

now() {
	echo -n `date +%s` `date +"%F %H:%M:%S %:z"`
}

mkdir -p $base_dir
output_dir=$base_dir/`date +"%Y%m%d-%H%M"`
mkdir -p $output_dir

# start time
echo "> Experimetns-Start: `now`"

for i in "${regions[@]}"
do
	server=$region_prefix$i
	mkdir -p $output_dir/$i

	echo ">> $i-Region-Start: `now`"

	for j in "${regions[@]}"
	do
		client=$region_prefix$j
		output=$output_dir/$i/$j.txt

		echo ">>> $i-$j: `now`"

		# start client
		ssh $ssh_option $server -l $user $server_command $server_option $client > $output
	done

	echo ">> $i-Region-End: b`now`"
done

# finish time
echo "> Experiments-Finish: `now`"
