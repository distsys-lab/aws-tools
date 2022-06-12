#!/bin/sh

if [ $# -lt 2 ]; then
	echo 'usage: region-name friendly-name'
	exit 1
fi

name=$2
name_prefix=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`
group=`cat config.txt | grep '^name_prefix' | cut -d '=' -f 2-`

region=$1
option="--region $region --output json"

subnet="10.0.0.0/16"
key_name=`cat config.txt | grep '^keypair_name' | cut -d '=' -f 2-`
pubkey_path=`cat config.txt | grep '^pubkey_path' | cut -d '=' -f 2-`

echo create a vpc
vpcid=`aws ec2 $option create-vpc --cidr-block $subnet --no-amazon-provided-ipv6-cidr-block --instance-tenancy default | jq .Vpc.VpcId | sed 's/"//g'`
echo tag the vpc
aws ec2 $option create-tags --resource $vpcid --tags "Key=Name,Value=$name_prefix$name"
aws ec2 $option create-tags --resource $vpcid --tags "Key=Group,Value=$group"

echo create a subnet for the vpc
subnetid=`aws ec2 $option create-subnet --cidr-block $subnet --vpc-id $vpcid | jq .Subnet.SubnetId | sed 's/"//g'`
echo tag the subnet
aws ec2 $option create-tags --resource $subnetid --tags "Key=Name,Value=$name_prefix$name-subnet"
aws ec2 $option create-tags --resource $subnetid --tags "Key=Group,Value=$group"

echo create a internet gateway
igid=`aws ec2 $option create-internet-gateway | jq .InternetGateway.InternetGatewayId | sed 's/"//g'`
echo assign the internet gateway to the vpc
aws ec2 $option attach-internet-gateway --internet-gateway-id $igid --vpc-id $vpcid
echo tag the internet gateway
aws ec2 $option create-tags --resource $igid --tags "Key=Name,Value=$name_prefix$name-gateway"
aws ec2 $option create-tags --resource $igid --tags "Key=Group,Value=$group"

echo get the route table id of the vpc
rtbid=`aws ec2 $option describe-route-tables --filters "Name=vpc-id,Values=$vpcid" | jq ".RouteTables[0].RouteTableId" | sed 's/"//g'`
echo add the gateway to the vpc\'s route table
aws ec2 $option create-route --destination-cidr-block 0.0.0.0/0 --gateway-id $igid --route-table-id $rtbid

echo create a security group for the vpc
sgid=`aws ec2 $option create-security-group --group-name $name_prefix$name-sg --description 'bft test security group' --vpc-id $vpcid | jq .GroupId | sed 's/"//g'`
echo add ingress rules to the security group
aws ec2 $option authorize-security-group-ingress --group-id $sgid --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 $option authorize-security-group-ingress --group-id $sgid --protocol tcp --port 10000-65535 --cidr 0.0.0.0/0
aws ec2 $option  authorize-security-group-ingress --group-id $sgid --protocol icmp --port -1 --cidr 0.0.0.0/0

echo register public key to the region $region
aws ec2 $option import-key-pair --key-name $keyname --public-key-material file://$pubkey_path

echo vpc-id: $vpcid
echo subnet-id: $subnetid
echo igid-id: $igid
echo rtbid-id: $rtbid
echo sgid-id: $sgid
