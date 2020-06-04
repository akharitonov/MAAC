#!/bin/sh

# Prefix for container names
PFX=${1:-""}

# Dropbox token
DBOX_TOKEN=${2:-""}

# Dropbox folder
DBOX_FOLDER=${3:-"/maac_exp"}

REPEATS=${4:-3}

# build the image
docker build -t ${PFX}maac:latest -f cpu.Dockerfile . --no-cache

# run each scenario in a separate container
max=5
for IDX in $(seq 0 $max)
do
    docker run -d -e dboxtoken=${DBOX_TOKEN} -e dboxdir=${DBOX_FOLDER}/scen_${IDX} -e repeats=${REPEATS} -e scenario=${IDX} --name ${PFX}maac_${IDX} \
    -v ${PFX}maac-vres_${IDX}:/results --shm-size=8gb ${PFX}maac:latest
done
