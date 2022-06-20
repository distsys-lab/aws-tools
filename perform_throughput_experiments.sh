#!/bin/bash

#set -x
hosts_list=`cat config.txt | grep '^hosts_list' | cut -d '=' -f 2-`

# use UTC throughout the experiment
export TZ=UTC

# results will be stored here
base_dir=~/Desktop/aws-tools/data/aws-inter-region-throughput

ssh_option="-i ~/.ssh/cloud-experiment"

#regions=(ohio virginia california oregon mumbai seoul singapore sydney tokyo canada frankfurt ireland london saopaulo)
regions=(ohio n.virginia)
region_prefix=bft-

user=ubuntu

server_command=iperf3
server_option="-s -p 10000 -i 0 -D"

client_command="iperf3 -c"
client_option="-p 10000"

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
	server_ip=`cat $hosts_list | grep $server | cut -d '=' -f 1`
	mkdir -p $output_dir/$i

	echo ">> $i-Region-Start: `now`"

	# start server
	ssh $ssh_option $server_ip -l $user $server_command $server_option

	for j in "${regions[@]}"
	do
		client=$region_prefix$j
		client_ip=`cat $hosts_list | grep $client | cut -d '=' -f 1`
		output=$output_dir/$i/$j.txt

		echo ">>> $i-$j: `now`"
		# start client
		ssh $ssh_option $client_ip -l $user $client_command $server_ip $client_option > $output
	done

	# cleanup iperf daemon
	ssh $ssh_option $server_ip -l $user pkill $server_command

	echo ">> $i-Region-End: `now`"
done

# finish time
echo "> Experiments-Finish: `now`"
