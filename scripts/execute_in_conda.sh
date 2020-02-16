#!/bin/bash

source ~/miniconda/etc/profile.d/conda.sh
conda activate maac

if [ "$#" -eq 2 ];then
    if [ "$2" = "gpu" ];then
        python experiment.py --local-dir /results --r "$1" --use_gpu
    else
        python experiment.py --local-dir /results --r "$1"
    fi    
elif [ "$#" -eq 4 ];then
    if [ "$4" = "gpu" ];then
        python experiment.py --local-dir /results --r "$1" --dbox-token "$2" --dbox-dir "$3" --use_gpu
    else
        python experiment.py --local-dir /results --r "$1" --dbox-token "$2" --dbox-dir "$3"
    fi
else
    echo Incorrect number of arguments >&2
fi