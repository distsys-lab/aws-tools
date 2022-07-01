#!/bin/bash

#set -x

hosts_list=`cat config.txt | grep '^hosts_list' | cut -d '=' -f 2-`

# use UTC throughout the experiment
export TZ=UTC

# results will be stored here
base_dir=~/aws-tools/data/aws-inter-region-rtt

ssh_option="-i ~/.ssh/id_rsa -y"

#regions=(ohio virginia california oregon mumbai seoul singapore sydney tokyo canada frankfurt ireland london saopaulo)
regions=(`cat my-hosts-list.txt | cut -d ":" -f 1`) #automatic selection from "my-hosts-list.txt"
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

	server_ip=`cat $hosts_list | grep $i | cut -d ':' -f 2`
	mkdir -p $output_dir/$i

	echo ">> $i-Region-Start: `now`"

	for j in "${regions[@]}"
	do
		client_ip=`cat $hosts_list | grep $j | cut -d ':' -f 2`
		output=$output_dir/$i/$j.txt

		echo ">>> $i-$j: `now`"

		# start client
		ssh -oStrictHostKeyChecking=no $ssh_option $server_ip -l $user $server_command $server_option $client_ip > $output
	done

	echo ">> $i-Region-End: b`now`"
done

# finish time
echo "> Experiments-Finish: `now`"
