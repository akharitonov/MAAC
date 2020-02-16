#!/bin/bash

# Create Conda environment with the dependencies suggested in the original MAAC publication

cfg="gpu"
if [ "$#" -eq 1 ];then
    cfg="$1"
fi

source ~/miniconda/etc/profile.d/conda.sh
conda create -y --name maac python=3.6
conda activate maac

base_dir=/code

# Install PyTorch with dependencies
pip install --progress-bar off gym==0.9.4
#pip install --progress-bar off tensorboard-pytorch==0.4
pip install --progress-bar off tensorboardX==1.1
pip install --progress-bar off tensorboard==1.0.0a6
pip install --progress-bar off seaborn==0.9.0

if [ "$cfg" = "gpu" ];then
    pip install --progress-bar off -U https://download.pytorch.org/whl/cu75/torch-0.3.0.post4-cp36-cp36m-linux_x86_64.whl
elif [ "$cfg" = "cpu" ];then
    conda install pytorch=0.3.0 -c pytorch
else
    echo "Incorrect configuration argument '$cfg'" >&2
    exit 1
fi

# Install baselines
git clone -n --single-branch https://github.com/openai/baselines.git "$base_dir/baselines"
cd "$base_dir/baselines"
git checkout 98257ef8c9bd23a24a330731ae54ed086d9ce4a7
pip install --progress-bar off -e .
cd "$base_dir"

# Install MPE
# Intall MPE with dependencies
git clone --single-branch --branch maac https://github.com/jcridev/multiagent-particle-envs.git "$base_dir/MPE"
cd "$base_dir/MPE"
pip install --progress-bar off -e .

# Move custom scenarios to MPE
mv "$base_dir/envs/mpe_scenarios/fullobs_collect_treasure.py" "$base_dir/MPE/multiagent/scenarios/fullobs_collect_treasure.py"
mv "$base_dir/envs/mpe_scenarios/multi_speaker_listener.py" "$base_dir/MPE/multiagent/scenarios/multi_speaker_listener.py"
#rm -rf "$base_dir/envs"

cd $base_dir
pip install --progress-bar off opencv-python==4.1.0.25
pip install --progress-bar off pandas==0.25.1
pip install --progress-bar off setproctitle==1.1.10
pip install --progress-bar off box2d-py

conda deactivate
