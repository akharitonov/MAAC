#!/bin/bash

source ~/miniconda/etc/profile.d/conda.sh
conda activate maac

pip install --progress-bar off requests
pip install --progress-bar off dropbox

conda deactivate