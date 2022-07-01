#!/bin/bash

echo "StartTime -----> `date`"
./start_instances_on_all_regions.sh
./perform_throughput_experiments.sh
./perform_rtt_experiments.sh
./stop_instances_on_all_regions.sh
echo "EndTime -----> `date`"