# aws-tools

These tools provide various functions to manage many instances in many regions all together.

## Prerequisites

* [AWS CLI](https://aws.amazon.com/cli/)

## Description

The configuration of these tools is written in `config.txt` as follows.
You can modify them as you want.
```
# this prefix will be added to all resources that will be created
name_prefix=my-bft
# the name of a key pair that will be created
keypair_name=my-keypair
# the path to your public key, which will be used as your aws key pair
pubkey_path='~/.ssh/id_rsa.pub'
# instance type
instance_type=t2.micro
# a list of regions where this toolset manages
region_list=my-region-list.txt
# a list of OS image IDs for your instances
image_list=my-image-list.txt
```

Most tools in this repository need a region list to specify the target regions of the tools.
File `available-regions.txt` is a list of all available regions.
Create your own region list by deleting unnecessary lines (i.e., regions) of the file and specify it in `config.txt`.
Note that, currently these tools does not allow a user to specify availability zones where instances run.

You also need an OS image list from which an instance will be boot.
Even if you want to run an instance with the same OS image such as Ubuntu 22.04, the image ID differs among regions.
Therefore, you have to prepare a list including a OS image ID for each region before launching an instance.
You can create this list as follows.
```
./list_ami_of_all_regions.sh
```
If you want to change a search keyword for OS images, edit `search_words_prefix` in `list_ami_of_all_regions.sh`.

These tools add prefix `name_prefix` defined in `config.txt` in the name of a resource to distinguish which resource are managed by the tools.

## Start and stop instances

Create and run an instance in `region-name `with `friendly-name` and `image-id`.
```
./run_instance.sh region-name friendly-name image-id'
```

Create and run instances in all the regions.
```
./create_and_run_instances_on_all_regions.sh
```

Start the existing instances in all the regions.
```
./start_instances_on_all_regions.sh
```

Stop the existing instances in all the regions.
```
./stop_instances_on_all_regions.sh
```

## Terminate instances

Terminate the instance `instance-id` in region `region-name`.
Note that this operation **deletes** an instance, not stop.
```
./terminate_instance.sh region-name instance-id'
```

Terminate all the instances in all the regions.
```
./terminate_all_instances.sh
```

## Manage Virtual Private Clouds (VPCs)

Create a VPC in `region-name` with name `friendly-name` and configure it to run an instance.
```
./create_my_vpc.sh region-name friendly-name'
```

Create VPCs in all regions.
```
./create_my_vpcs_on_all_regions.sh
```

Delete a VPC whose name is `friendly-name` in region `region-name`.
```
./delete_my_vpc.sh region-name friendly-name'
```

Delete all VPCs in all regions.
```
./delete_my_vpcs_on_all_regions.sh
```

## Manage Elastic IPs

Get an elastic IP associating with instance `instance-id` back and release it.
```
./disassociate_and_release_eip.sh region-name instance-id'
```

Release all elastic IPs.
```
./release_all_elastic_ips.sh
```

## Show instance-related information

Show all instances in all regions.
```
./list_instances_on_all_regions.sh
```

Show all elastic IPs in all regions.
```
./list_all_elastic_ips.sh
```

Show all availability zones in all regions.
```
./list_regions_and_availability_zones.sh
```

Show all Ubuntu image IDs in all regions.
```
list_ubuntu_ami_of_all_regions.sh
```

## Misc

Install packages and distribute configuration files to the host whose IP is `hostip`.
```
./remote_setup.sh hostip
```

Add a policy to the security group of VPC `friendly-name` in region `region-name`
```
add_rule_to_vpc.sh region-name friendly-name'
```
## Experiment Preparation

One IP address is specified for one host name.

```
./list_instances_on_all_regions.sh | cut -d ':' -f 2,4 > my-hosts-list.txt
```

## Perform experiments

See the scripts below.
```
./perform_rtt_experiments.sh
./perform_throughput_experiments.sh
```
