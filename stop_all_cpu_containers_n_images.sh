#!/bin/bash

# Prefix for container names
PFX=${1:-""}

max=5
for i in $(seq 0 $max)
do
    docker container stop ${PFX}maac_$i
done

for SCEN_IDX in $(seq 0 5)
do
    for EXP_IDX in $(seq 0 3)
    do
      docker container stop ${PFX}maac_${SCEN_IDX}_${EXP_IDX}
    done
done