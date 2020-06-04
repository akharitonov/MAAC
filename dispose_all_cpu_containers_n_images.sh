#!/bin/bash

# Prefix for container names
PFX=${1:-""}


max=5
for i in $(seq 0 $max)
do
    docker container rm -v ${PFX}maac_$i
    docker volume rm ${PFX}maac-vres_$i
done


docker image rm ${PFX}maac:latest
