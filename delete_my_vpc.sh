#!/bin/sh

if [ $# -lt 2 ]; then
>---echo 'usage: region-name friendly-name'
>---exit 1
fi

is_dryrun=''

name=$2
name_prefix=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`
gruop=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`

region=$1
option="--region $region --output json"

# get vpc list
vn=${name_prefix}${name}
vpcs=`aws ec2 $option describe-vpcs | jq -r ".Vpcs[] | select(.Tags[]?.Value == \"$vn\") | .VpcId"`
for i in $vpcs
do
	echo vpc id: $i
done

# delete security groups
gn=${name_prefix}${name}-sg
sgs=`aws ec2 $option describe-security-groups --filters Name=group-name,Values=$gn | jq -r .SecurityGroups[].GroupId`
for i in $sgs
do
	echo delete segurity group: $i
	aws ec2 $option delete-security-group --group-id $i $is_dryrun
done

# delete subnets
for i in $vpcs
do
	sns=`aws ec2 $option describe-subnets --filters Name=vpc-id,Values=$i | jq -r .Subnets[].SubnetId`
	for j in $sns
	do
		echo delete subnet $j for vpc $i
		aws ec2 $option delete-subnet --subnet-id $j $is_dryrun
	done
done

## disassociate route tables
#for i in $vpcs
#do
#	as=`aws ec2 $option describe-route-tables --filters Name=vpc-id,Values=$i | jq -r .RouteTables[].Associations[].RouteTableAssociationId`
#	for j in $as
#	do
#		echo disassociate route table $j for vpc $i
#		aws ec2 $option disassociate-route-table --association-id $j $is_dryrun
#	done
#done
#
## delete route tables
#for i in $vpcs
#do
#	rts=`aws ec2 $option describe-route-tables --filters Name=vpc-id,Values=$i | jq -r .RouteTables[].RouteTableId`
#	for j in $rts
#	do
#		echo delete route table $j for vpc $i
#		aws ec2 $option delete-route-table --route-table-id $j $is_dryrun
#	done
#done

# delete internet gateways
for i in $vpcs
do
	igws=`aws ec2 $option describe-internet-gateways --filters Name=attachment.vpc-id,Values=$i | jq -r .InternetGateways[].InternetGatewayId`
	for j in $igws
	do
		echo detach internet gateway $j for vpc $i
		aws ec2 $option detach-internet-gateway --internet-gateway-id $j --vpc-id $i $is_dryrun
		echo delete internet gateway $j for vpc $i
		aws ec2 $option delete-internet-gateway --internet-gateway-id $j $is_dryrun
	done
done

# delete vpcs
for i in $vpcs
do
	echo delete vpc $i
	aws ec2 $option delete-vpc --vpc-id $i $is_dryrun
done
