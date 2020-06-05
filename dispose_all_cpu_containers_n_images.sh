#!/bin/bash

# Prefix for container names
PFX=${1:-""}


for SCEN_IDX in $(seq 0 5)
do
    for EXP_IDX in $(seq 0 3)
    do
      docker container rm -v ${PFX}maac_${SCEN_IDX}_${EXP_IDX}
      docker volume rm ${PFX}maac-vres_${SCEN_IDX}_${EXP_IDX}
    done
done


docker image rm ${PFX}maac:latest
