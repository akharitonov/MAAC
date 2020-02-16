#!/bin/bash

cfg="gpu"
if [ "$#" -eq 1 ];then
    cfg="$1"
fi

source ~/miniconda/etc/profile.d/conda.sh
conda create -y --name maac python=3.7
conda activate maac

base_dir=/code

# Install PyTorch with dependencies
pip install --progress-bar off gym==0.9.4
pip install --progress-bar off tensorboardx==1.9
pip install --progress-bar off tensorboard==2.0.0
pip install --progress-bar off seaborn==0.9.0

if [ "$cfg" = "gpu" ];then
    pip install --progress-bar off torch==1.4.0+cu92 torchvision==0.5.0+cu92 -f https://download.pytorch.org/whl/torch_stable.html
elif [ "$cfg" = "cpu" ];then
    pip install --progress-bar off torch==1.4.0+cpu torchvision==0.5.0+cpu -f https://download.pytorch.org/whl/torch_stable.html
else
    echo "Incorrect configuration argument '$cfg'" >&2
    exit 1
fi


#conda install pytorch==1.1.0 torchvision==0.3.0 cudatoolkit=9.0 -c pytorch
#https://pytorch.org/get-started/previous-versions/

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
