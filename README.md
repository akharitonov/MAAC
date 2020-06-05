# Multi-Actor-Attention-Critic - code and docker images for running experiments

## Choose a Docker image to build.

### Docker image of the original dependencies (CPU)
This docker image contains the dependencies suggested in the original publication. Many of these dependencies are heavily outdated, a more up to date image is also provided (described further below). 

```
docker build -t maac:latest -f original.Dockerfile .
```

### Docker image of the original dependencies (CUDA)
This docker image contains the dependencies suggested in the original publication. Many of these dependencies are heavily outdated, a more up to date image is also provided (described further below). 

```
docker build -t maac:latest -f cuda-original.Dockerfile .
```

### Docker image with more relevant dependencies versions (CPU)

This docker image depends on versions of MAAC dependencies that were released recently, yet compatible with MAAC code. 

```
docker build -t maac:latest -f cpu.Dockerfile .
```

### Docker image with more relevant dependencies versions (CUDA)

This docker image depends on versions of MAAC dependencies that were released recently, yet compatible with MAAC code. 

```
docker build -t maac:latest -f cuda.Dockerfile .
```


## Start the container

Environment parameters:
* `repeats` - number of experiment repetitions
* `dboxtoken` - (optional) your Dropbox token
* `dboxdir` - directory in the Dropbox where the results will be uploaded. Must be empty or non existent. **Should only be defined when `dboxtoken` is supplied**

If you want the results to be uploaded to Dropbox, you'll need to setup an app in your account [App console](https://www.dropbox.com/developers/apps) in order to get a token.

```
docker run \
 -e repeats=5 \
 -e dboxtoken=YOUR_TOKEN \
 -e dboxdir=/epxeriment_1 \
 -e scenario=-1 \
 -e experiment=-1 \
 --name maac \
 --shm-size=4gb \
 -v maac-vres:/results \
 maac:latest
```

Note. Depending on your docker configuration of nvidia, you might need to also pass `--gpus` argument to the `run` command (Example: `--gpus all`). Refer to the [official nvidia-docker documentation](https://github.com/NVIDIA/nvidia-docker) for more information.

After the container experiments finish, the container quits. If you didn't supply a valid Dropbox token, you'll need to get the results from the mounted volume. You can access a volume with a *dummy* container attacched to that volume. Example using [Docker `cp`](https://docs.docker.com/engine/reference/commandline/cp/):
```
docker container create --name maac-dummy \
    -v maac-vres:/results \ 
    hello-world

mkdir -p ./results  

docker cp maac-dummy:/results ./results

docker rm maac-dummy
```

Cleanup
```
docker stop maac
docker rm maac
```


***
Fork of [shariqiqbal2810/MAAC](https://github.com/shariqiqbal2810/MAAC)
***
***
# Original README
# Multi-Actor-Attention-Critic
Code for [*Actor-Attention-Critic for Multi-Agent Reinforcement Learning*](https://arxiv.org/abs/1810.02912) (Iqbal and Sha, ICML 2019)

## Requirements
* Python 3.6.1 (Minimum)
* [OpenAI baselines](https://github.com/openai/baselines), commit hash: 98257ef8c9bd23a24a330731ae54ed086d9ce4a7
* My [fork](https://github.com/shariqiqbal2810/multiagent-particle-envs) of Multi-agent Particle Environments
* [PyTorch](http://pytorch.org/), version: 0.3.0.post4
* [OpenAI Gym](https://github.com/openai/gym), version: 0.9.4
* [Tensorboard](https://github.com/tensorflow/tensorboard), version: 0.4.0rc3 and [Tensorboard-Pytorch](https://github.com/lanpa/tensorboard-pytorch), version: 1.0 (for logging)

The versions are just what I used and not necessarily strict requirements.

## How to Run

All training code is contained within `main.py`. To view options simply run:

```
python main.py --help
```
The "Cooperative Treasure Collection" environment from our paper is referred to as `fullobs_collect_treasure` in this repo, and "Rover-Tower" is referred to as `multi_speaker_listener`.

In order to match our experiments, the maximum episode length should be set to 100 for Cooperative Treasure Collection and 25 for Rover-Tower.

## Citing our work

If you use this repo in your work, please consider citing the corresponding paper:

```
@InProceedings{pmlr-v97-iqbal19a,
  title =    {Actor-Attention-Critic for Multi-Agent Reinforcement Learning},
  author =   {Iqbal, Shariq and Sha, Fei},
  booktitle =    {Proceedings of the 36th International Conference on Machine Learning},
  pages =    {2961--2970},
  year =     {2019},
  editor =   {Chaudhuri, Kamalika and Salakhutdinov, Ruslan},
  volume =   {97},
  series =   {Proceedings of Machine Learning Research},
  address =      {Long Beach, California, USA},
  month =    {09--15 Jun},
  publisher =    {PMLR},
  pdf =      {http://proceedings.mlr.press/v97/iqbal19a/iqbal19a.pdf},
  url =      {http://proceedings.mlr.press/v97/iqbal19a.html},
}
```
