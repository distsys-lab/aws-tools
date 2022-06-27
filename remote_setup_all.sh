#!/bin/sh

regions=(`cat my-hosts-list.txt | cut -d "=" -f 2`)
for i in "${regions[@]}"
do
    ./remote_setup.sh $i
done