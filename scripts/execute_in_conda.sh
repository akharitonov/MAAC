#!/bin/bash

source ~/miniconda/etc/profile.d/conda.sh
conda activate maac

if [ "$#" -eq 3 ];then
    if [ "$3" = "gpu" ];then
        python experiment.py --local-dir /results --r "$1" --scenario "$2" --use_gpu
    else
        python experiment.py --local-dir /results --r "$1" --scenario "$2"
    fi    
elif [ "$#" -eq 5 ];then
    if [ "$5" = "gpu" ];then
        python experiment.py --local-dir /results --r "$1" --scenario "$2" --dbox-token "$3" --dbox-dir "$4" --use_gpu
    else
        python experiment.py --local-dir /results --r "$1" --scenario "$2" --dbox-token "$3" --dbox-dir "$4"
    fi
else
    echo Incorrect number of arguments >&2
fi