#!/bin/sh

# Prefix for container names
PFX=${1:-""}

# Dropbox token
DBOX_TOKEN=${2:-""}

# Dropbox folder
DBOX_FOLDER=${3:-"/maac_exp"}

REPEATS=${4:-1}

# build the image
docker build -t ${PFX}maac:latest -f cpu.Dockerfile . --no-cache

# run each scenario in a separate container
for SCEN_IDX in $(seq 0 5)
do
    for EXP_IDX in $(seq 0 3)
    do
      docker run -d -e dboxtoken=${DBOX_TOKEN} -e dboxdir=${DBOX_FOLDER}/scen_${SCEN_IDX}_${EXP_IDX} \
      -e repeats=${REPEATS} -e scenario=${SCEN_IDX} -e experiment=${EXP_IDX} \
      --name ${PFX}maac_${SCEN_IDX}_${EXP_IDX} \
      -v ${PFX}maac-vres_${SCEN_IDX}_${EXP_IDX}:/results --shm-size=8gb ${PFX}maac:latest
    done
done
