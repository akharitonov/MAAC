#!/bin/bash

# Prefix for container names
PFX=${1:-""}

max=5
for i in $(seq 0 $max)
do
    docker container stop ${PFX}maac-rllib_$i
done
