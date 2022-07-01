#!/bin/sh

for i in `cat my-hosts-list.txt | cut -d ":" -f 2`
do
    ./remote_setup.sh $i
done
